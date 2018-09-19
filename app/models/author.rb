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

  private

  # True if items are blank, or items are present and none remain to be imported
  def items_all_imported?
    stories_all_imported = stories.blank? || (stories.present? && stories.none?(&:to_be_imported))
    story_links_all_imported = story_links.blank? || (story_links.present? && story_links.none?(&:to_be_imported))

    (stories_all_imported && story_links_all_imported)
  end
end
