class Bookmark < ApplicationRecord
  belongs_to :author
  audited comment_required: true, associated_with: :author

  def coauthor?
    false
  end
end
