# frozen_string_literal: true

class Author < ApplicationRecord
  audited comment_required: true
  has_associated_audits

  has_many :stories, (-> { order(Arel.sql('lower(title)')) })
  has_many :story_links, (-> { order Arel.sql('lower(title)') })
  default_scope { order Arel.sql('lower(name)') }
  # All items
  scope :with_stories, (-> { joins(:stories).where("stories.id IS NOT NULL") })
  scope :with_story_links, (-> { joins(:story_links).where("story_links.id IS NOT NULL") })
  scope :with_stories_or_story_links, (-> { (with_stories + with_story_links).uniq })
  # Front-end scopes
  scope :by_letter, ->(letter) { where("substr(upper(name), 1, 1) = '#{letter}'") }
  scope :by_letter_with_items, ->(letter) { by_letter(letter).merge(with_stories_or_story_links) }

  validates_presence_of :name

  def all_imported?
    do_not_import || items_all_imported?
  end

  def coauthored_stories
    Story.where(coauthor_id: id)
  end

  def stories_with_chapters
    Story.where(author_id: id).joins(:chapters).group(:id)
  end

  def all_items_as_json
    {
      stories: stories_with_chapters.as_json(include: { chapters: { only: [:id, :title, :position] } }),
      story_links: story_links,
      coauthored: coauthored_stories
    }
  end

  def works_and_bookmarks(archivist, collection_name, host)
    works = stories.map { |s| s.to_work(collection_name, host) }
    bookmarks = story_links.map { |b| b.to_bookmark(archivist, collection_name) }
    [works, bookmarks]
  end

  def self.all_letters
    Author.with_stories_or_story_links.map do |a|
      {
        id: a.id,
        name: a.name,
        imported: a.imported,
        s_to_import: a.stories.where(imported: false).count,
        l_to_import: a.story_links.where(imported: false).count
      }
    end.group_by { |a| a[:name][0].upcase }
  end

  def import(client, collection_name, host)
    if do_not_import
      response =
        {
          status: :unprocessable_entity,
          messages: ["This author is set to do NOT import."],
          works: [],
          bookmarks: []
        }
    else
      works, bookmarks = works_and_bookmarks(client.config.archivist, collection_name, host)

      # Perform Archive request
      ao3_response = client.import(works: works, bookmarks: bookmarks)

      # Apply Archive response to items in the database 
      response = items_responses(ao3_response)
    end

    author_response(client, response)
  end

  def check(client, collection_name, host)
    works, bookmarks = works_and_bookmarks(client.config.archivist, collection_name, host)

    ao3_response = client.search(works: works, bookmarks: bookmarks)
    response = items_responses(ao3_response)

    author_response(client, response)
  end

  private

  def author_response(client, response)
    # Is the author now fully imported?
    imported = all_imported?
    response[:author_imported] = imported
    response[:author_id] = id
    response[:remote_host] = client.config.archive_host

    # Update audit and return response
    imported_status = "Import request processed. #{imported ? 'Author is now fully imported.' : 'Author still has some items to import.'}"
    update_attributes!(imported: imported, audit_comment: imported_status)
    response
  end

  def items_responses(ao3_response)
    response = {}
    has_success = ao3_response[0][:success]

    bookmarks_responses = ao3_response[1] ? ao3_response[1][:body][:bookmarks] : ao3_response[0][:body][:bookmarks]
    response[:bookmarks] = update_items(bookmarks_responses, :bookmark)

    response[:works] = ao3_response[0][:body][:works] ? update_items(ao3_response[0][:body][:works], :story) : []
    response[:messages] = ao3_response[0][:body][:messages]
    response[:status] = ao3_response[0][:status] || "ok"
    response[:success] = has_success
    response
  end

  def update_items(items_responses, type)
    responses = {}
    if items_responses.present?
      items_responses.each do |item_response|
        responses.merge!(Item.update_item(type, item_response.symbolize_keys))
      end
    end
    responses
  end

  def has_items?
    stories.present? || story_links.present?
  end

  # True if items are blank, or items are present and none remain to be imported
  def items_all_imported?
    stories_all_imported = stories.blank? || (stories.present? && stories.none?(&:to_be_imported))
    story_links_all_imported = story_links.blank? || (story_links.present? && story_links.none?(&:to_be_imported))

    (stories_all_imported && story_links_all_imported)
  end
end
