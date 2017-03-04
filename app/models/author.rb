class Author < ApplicationRecord
  has_many :stories, -> { order 'lower(title)' }
  has_many :bookmarks, -> { order 'lower(title)' }
  default_scope { order 'lower(name)' }
  scope :with_stories, -> { joins(:stories).where("stories.id IS NOT NULL") }
  scope :with_bookmarks, -> { joins(:bookmarks).where("bookmarks.id IS NOT NULL") }
  scope :with_stories_or_bookmarks, -> { (with_stories + with_bookmarks).uniq }

  validates_presence_of :name

  def coauthored_stories
    Story.where(coauthor_id: self.id)
  end
end
