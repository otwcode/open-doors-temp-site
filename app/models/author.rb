class Author < ApplicationRecord
  audited comment_required: true
  has_associated_audits

  has_many :stories, (-> { order 'lower(title)' })
  has_many :story_links, (-> { order 'lower(title)' })
  default_scope { order 'lower(name)' }
  scope :with_stories, (-> { joins(:stories).where("stories.id IS NOT NULL") })
  scope :with_story_links, (-> { joins(:story_links).where("story_links.id IS NOT NULL") })
  scope :with_stories_or_story_links, (-> { (with_stories + with_story_links).uniq })

  validates_presence_of :name

  def all_imported?
    stories_not_imported = stories.present? && stories.none?(&:to_be_imported)
    story_links_not_imported = story_links.present? && story_links.none?(&:to_be_imported)

    (stories_not_imported && story_links_not_imported) ||
      (stories_not_imported && story_links.blank?) ||
        (stories.blank? & story_links_not_imported) ||
        self.imported || self.do_not_import
  end

  def coauthored_stories
    Story.where(coauthor_id: id)
  end

  def works_and_bookmarks(archivist, collection_name, host)
    works = stories.map { |s| s.to_work(collection_name, host) }
    bookmarks = story_links.map { |b| b.to_bookmark(archivist, collection_name) }
    [works, bookmarks]
  end
end
