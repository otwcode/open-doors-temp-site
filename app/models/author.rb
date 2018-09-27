class Author < ApplicationRecord
  audited comment_required: true
  has_associated_audits

  has_many :stories, (-> { order Arel.sql('lower(title)') })
  has_many :story_links, (-> { order Arel.sql('lower(title)') })
  default_scope { order Arel.sql('lower(name)') }
  # All items
  scope :with_stories, (-> { joins(:stories).where("stories.id IS NOT NULL") })
  scope :with_story_links, (-> { joins(:story_links).where("story_links.id IS NOT NULL") })
  scope :with_stories_or_story_links, (-> { (with_stories + with_story_links).uniq })
  
  validates_presence_of :name

  def all_imported?
    self.imported || self.do_not_import || items_all_imported?
  end

  def coauthored_stories
    Story.where(coauthor_id: id)
  end

  def works_and_bookmarks(archivist, collection_name, host)
    works = stories.map { |s| s.to_work(collection_name, host) }
    bookmarks = story_links.map { |b| b.to_bookmark(archivist, collection_name) }
    [works, bookmarks]
  end

  def import(client, collection_name, host)
    response = {}
    if self.do_not_import
      response = 
        {
          status: :unprocessable_entity,
          messages: [
            "This author is set to do NOT import."
          ],
          works: [],
          bookmarks: []
        }
    else
      works, bookmarks =
        self.works_and_bookmarks(client.config.archivist, collection_name, host)

      # Perform Archive request
      ao3_response = client.import(works: works, bookmarks: bookmarks)

      # Apply Archive response to items in the database
      works_responses = ao3_response[0]["works"]
      if works_responses.present?
        works_responses.each do |work_response|
          update_item(:story, work_response.symbolize_keys)
        end
        response["works"] = works_responses
      end

      bookmarks_responses = ao3_response[1] ? ao3_response[1]["bookmarks"] : ao3_response[0]["bookmarks"]
      if bookmarks_responses.present?
        bookmarks_responses.each do |bookmark_response|
          update_item(:bookmark, bookmark_response.symbolize_keys)
        end
        response["bookmarks"] = bookmarks_responses
      end
    end

    # Is the author now fully imported?
    response[:author_imported] = self.all_imported?
    response[:author_id] = self.id
    response
  end

  def check(client, collection_name, host)
    works, bookmarks =
      self.works_and_bookmarks(client.config.archivist, collection_name, host)

    response = client.search(works: works, bookmarks: bookmarks)

    works_responses = response[0]["works"]
    if works_responses.present?
      works_responses.each do |work_response|
        update_item(:story, work_response.symbolize_keys)
      end
    end

    bookmarks_responses = if response[1]
                            response[1]["bookmarks"]
                          else
                            response[0]["bookmarks"]
                          end
    if bookmarks_responses.present?
      bookmarks_responses.each do |bookmark_response|
        update_item(:bookmark, bookmark_response.symbolize_keys)
      end
    end

    # Is the author now fully imported?
    response[0][:author_imported] = author.all_imported?
    response
  end

  private

  # True if items are blank, or items are present and none remain to be imported
  def items_all_imported?
    stories_all_imported = stories.blank? || (stories.present? && stories.none?(&:to_be_imported))
    story_links_all_imported = story_links.blank? || (story_links.present? && story_links.none?(&:to_be_imported))

    (stories_all_imported && story_links_all_imported)
  end
end
