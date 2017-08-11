class StoryLink < ApplicationRecord
  include OtwArchive
  include OtwArchive::Request

  belongs_to :author
  audited comment_required: true, associated_with: :author

  def coauthor?
    false
  end

  def to_be_imported
    !self.imported && !self.do_not_import
  end

  def to_bookmark(archivist, collection)
    Request::Bookmark.new(
      archivist,
      id,
      url,
      author.name,
      title,
      summary,
      fandoms,
      rating,
      categories,
      relationships,
      characters,
      collection,
      notes,
      tags,
      false,
      false
    )
  end
end
