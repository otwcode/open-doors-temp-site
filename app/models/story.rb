class Story < ApplicationRecord
  audited comment_required: true, associated_with: :author

  belongs_to :author
  belongs_to :coauthor, foreign_key: :coauthor_id, class_name: "Author"
  has_many :chapters

  def coauthor?
    coauthor.present?
  end
end
