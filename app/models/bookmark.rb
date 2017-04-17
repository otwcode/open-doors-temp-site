class Bookmark < ApplicationRecord
  belongs_to :author

  def coauthor?
    false
  end
end
