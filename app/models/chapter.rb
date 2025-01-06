class Chapter < ApplicationRecord
  audited comment_required: true

  belongs_to :story

  self.primary_key = "id"
end
