class StoryLink < ApplicationRecord
  include OtwArchive
  include OtwArchive::Request
  include Item

  belongs_to :author
  audited comment_required: true, associated_with: :author

  def coauthor?
    false
  end

  def to_be_imported
    !self.imported && !self.do_not_import
  end

  def as_json(options = {})
    hash = super
    hash.merge!(
      errors: item_errors,
      date: convert_date(date),
      updated: convert_date(date)
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
      language_code,
      archive_config.collection_name,
      "#{archive_config.bookmarks_note}\n" +
        if notes.present?
          "<br/><br/><p>--</p><br/>#{notes}"
        else
          ""
        end,
      tags,
      false,
      false
    )
  end
end
