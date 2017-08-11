class Story < ApplicationRecord
  include OtwArchive
  include OtwArchive::Request
  include Rails.application.routes.url_helpers

  audited comment_required: true, associated_with: :author

  belongs_to :author
  belongs_to :coauthor, foreign_key: :coauthor_id, class_name: "Author"
  has_many :chapters

  def coauthor?
    coauthor.present?
  end

  def to_be_imported
    !self.imported && !self.do_not_import
  end

  def to_work(collection, host)
    Request::Work.new(
      title,
      author.name,
      author.email,
      (coauthor.nil? ? "" : coauthor.name),
      (coauthor.nil? ? "" : coauthor.email),
      collection,
      fandoms,
      warnings,
      characters,
      rating,
      relationships,
      categories,
      tags,
      notes,
      id,
      summary,
      chapters.map { |c| chapter_url(c, host: host) }
    )
  end
end
