# frozen_string_literal: true

class Author < ApplicationRecord
  audited comment_required: true
  has_associated_audits

  has_many :stories, (-> { order(Arel.sql('lower(stories.title)')) })
  has_many :story_links, (-> { order Arel.sql('lower(story_links.title)') })
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

  def author_errors
    errors = []
    errors << "Author '#{name}' has more than #{stories.size} stories - the Archive can only import #{NUMBER_OF_ITEMS} at a time" if stories.size > NUMBER_OF_ITEMS
    errors << "Author '#{name}' has more than #{story_links.size} stories - the Archive can only import #{NUMBER_OF_ITEMS} at a time" if story_links.size > NUMBER_OF_ITEMS
  end

  def items_errors
    story_errors = stories_with_chapters.map(&:item_errors).reject(&:empty?)
    link_errors = story_links.map(&:item_errors).reject(&:empty?)
    [story_errors, link_errors].compact.reduce([], :|)
  end

  def coauthored_stories
    Story.where(coauthor_id: id)
  end

  def stories_with_chapters
    stories.joins(:chapters).group(:id)
  end

  def all_items_as_json
    {
      author_imported: all_imported?,
      stories: stories_with_chapters.all.index_by { |s| s.id},
      story_links: story_links.all.index_by { |b| b.id },
      coauthored: coauthored_stories
    }
  end

  def works_and_bookmarks(archive_config, host)
    works = stories.map { |s| s.to_work(archive_config, host) }
    bookmarks = story_links.map { |b| b.to_bookmark(archive_config) }
    [works, bookmarks]
  end

  def self.all_letters
    Author.with_stories_or_story_links.map do |a|
      {
        id: a.id,
        name: a.name,
        imported: a.imported,
        s_to_import: a.stories.where(imported: false).count,
        l_to_import: a.story_links.where(imported: false).count,
        errors: [a.author_errors, a.items_errors].compact.reduce([], :|)
      }
    end.group_by { |a| a[:name][0].upcase }
  end

  def import(client, host)
    if do_not_import
      response =
        {
          status: :unprocessable_entity,
          messages: ["This author is set to do NOT import."],
          works: [],
          bookmarks: []
        }
    else
      works, bookmarks = works_and_bookmarks(client.config.archive_config, host)

      # Perform Archive request
      ao3_response = client.import(works: works, bookmarks: bookmarks)

      # Apply Archive response to items in the database 
      response = items_responses(ao3_response)
    end

    final_response = author_response(client, response)
    Rails.logger.info("........ author model > import ............")
    Rails.logger.info(final_response)
    final_response
  end

  def check(client, host)
    works, bookmarks = works_and_bookmarks(client.config.archive_config, host)

    ao3_response = client.search(works: works, bookmarks: bookmarks)
    response = items_responses(ao3_response)

    final_response = author_response(client, response)
    Rails.logger.info("........ author model > check ............")
    Rails.logger.info(final_response)
    final_response
  end

  private

  def author_response(client, response)
    stories.reload # :/
    story_links.reload
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

    response[:messages] = ao3_response[0][:body][:messages] || []
    response[:status] = ao3_response[0][:status] || "ok"

    response[:success] =
      if response[:works].values.all? { |w| ["created", "already_imported"].include?(w[:status]) } &&
         response[:bookmarks].values.all? { |w| ["created", "already_imported"].include?(w[:status]) }
        true
      else
        has_success
      end
    
    response
  end

  def update_items(items_responses, type)
    responses = {}
    if items_responses.present?
      items_responses.each do |item_response|
        update = Item.update_item(type, item_response.symbolize_keys)
        Rails.logger.info(update)
        responses.merge!(update)
      end
    end
    responses
  end

  def has_items?
    stories.present? || story_links.present?
  end

  # True if items are blank, or items are present and none remain to be imported
  def items_all_imported?
    stories_all_imported = stories.blank? || (stories.present? && stories.all? { |s| s.imported || s.do_not_import })
    story_links_all_imported = story_links.blank? || (story_links.present? && story_links.all? { |s| s.imported || s.do_not_import })
    all_imported = (stories_all_imported && story_links_all_imported)
    imported = all_imported if all_imported != imported
    imported
  end
end
