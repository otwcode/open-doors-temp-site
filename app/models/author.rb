# frozen_string_literal: true

class Author < ApplicationRecord
  include Item

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

  def self.all_errors(author_ids)
    all_errors = Author.size_errors(author_ids)
    item_errors = Item.all_errors(author_ids)
    item_errors.map do |a_id, errors|
      if all_errors.key?(a_id)
        all_errors[a_id].concat errors
      else
        all_errors[a_id] = errors
      end
    end
    all_errors
  end

  def self.size_errors(author_ids)
    author_errors = {}
    author_names = Author.where("id in (#{author_ids})").pluck(:id, :name).to_h
    
    items = [
      {model: Story, label: :stories},
      {model: StoryLink, label: :bookmarks}
    ]

    items.map do |item|
      errors = item[:model].where("author_id in (#{author_ids})").group(:author_id).having("count(id) > #{NUMBER_OF_ITEMS}").count
      errors.map do |a_id, count|
        msg = "Author '#{author_names[a_id]}' has more than #{count} #{item[:label]} - the Archive can only import #{NUMBER_OF_ITEMS} at a time"
        if author_errors.key?(a_id)
          author_errors[a_id] << msg
        else
          author_errors[a_id] = [msg]
        end
      end
    end

    author_errors
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
      stories: stories_with_chapters.all.index_by { |s| s.id },
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

  def self.all_imported
    non_imported_stories = Item.auth_id_to_not_imported_dni(Story)
    non_imported_links = Item.auth_id_to_not_imported_dni(StoryLink)
    authors = []
    Author.all.map do |a|
      s_to_import = non_imported_stories[a.id] || 0
      l_to_import = non_imported_links[a.id] || 0
      authors << a.id if s_to_import == 0 && l_to_import == 0
    end
    authors
  end

  def self.not_imported
    non_imported_stories = Item.auth_id_to_not_imported_dni(Story)
    non_imported_links = Item.auth_id_to_not_imported_dni(StoryLink)
    authors = []
    Author.with_stories_or_story_links.map do |a|
      s_to_import = non_imported_stories[a.id] || 0
      l_to_import = non_imported_links[a.id] || 0
      authors << a if s_to_import > 0 || l_to_import > 0
    end
    authors
  end

  def self.authors_by_letter(letter, page, page_size)
    offset = (page.to_i - 1) * page_size
    Author.left_outer_joins(:stories, :story_links).where(
      "substr(upper(name),1,1) = '#{letter}' and (stories.id IS NOT NULL or story_links.id IS NOT NULL)"
    ).order(:name).limit(page_size).offset(offset).distinct
  end

  def self.get_letter(letter, page, page_size)
    authors = Author.authors_by_letter(letter, page, page_size).to_a
    author_ids = authors.map(&:id).join(",")

    id_to_stories = Item.auth_id_to_not_imported(Story, author_ids)
    id_to_links = Item.auth_id_to_not_imported(StoryLink, author_ids)
    errors = Author.all_errors(author_ids)

    authors.map do |a|
      {
        id: a.id,
        name: a.name,
        imported: a.imported,
        s_to_import: id_to_stories[a.id] || 0,
        l_to_import: id_to_links[a.id] || 0,
        errors: errors[a.id] || []
      }
    end
  end

  def self.letter_counts
    letters = Author.with_stories_or_story_links.group_by { |a| a[:name][0].upcase }
    not_imported_letters = Author.not_imported.group_by { |a| a[:name][0].upcase }

    all_authors = Hash[letters.map{|k,v| [k,v.size]}]
    not_imported = Hash[not_imported_letters.map{|k,v| [k, v.size]}]
    
    letter_hash = {}
    all_authors.map do |letter,count|
      letter_hash[letter] = {
        all: count,
        imports: not_imported[letter] || 0
      }
    end
    letter_hash
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
      response = Item.items_responses(ao3_response)
    end

    final_response = author_response(client, response)
    Rails.logger.info("........ author model > import ............")
    Rails.logger.info(final_response)
    final_response
  end

  def check(client, host)
    works, bookmarks = works_and_bookmarks(client.config.archive_config, host)

    ao3_response = client.search(works: works, bookmarks: bookmarks)
    response = Item.items_responses(ao3_response, true)

    final_response = author_response(client, response)
    Rails.logger.info("........ author model > check ............")
    Rails.logger.info(final_response)
    final_response
  end

  # True if items are blank, or items are present and none remain to be imported
  def items_all_imported?
    stories_all_imported = stories.blank? || (stories.present? && stories.all? { |s| s.imported || s.do_not_import })
    story_links_all_imported = story_links.blank? || (story_links.present? && story_links.all? { |s| s.imported || s.do_not_import })
    all_imported = (stories_all_imported && story_links_all_imported)
    imported = all_imported if all_imported != imported
    imported
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

  def has_items?
    stories.present? || story_links.present?
  end

end
