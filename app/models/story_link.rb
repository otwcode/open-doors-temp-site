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

  def item_errors
    errors = []
    if summary.length > 1250
      errors << "Summary for story link '#{title}' is too long (#{summary.length})"
    end
    errors
  end

  def as_json(options = {})
    hash = super
    hash.merge!(
      errors: item_errors,
      date: date.strftime("%Y-%m-%d"),
      updated: date.strftime("%Y-%m-%d")
    )
  end

  def to_bookmark(archive_config)
    Request::Bookmark.new(
      archive_config.archivist,
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
      archive_config.collection_name,
      "#{archive_config.bookmarks_note}\n#{notes}",
      tags,
      false,
      false
    )
  end
end
