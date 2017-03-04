class Story < ApplicationRecord
  belongs_to :author
  has_one :coauthor, foreign_key: :id, class_name: 'Author'
  has_many :chapters
end
