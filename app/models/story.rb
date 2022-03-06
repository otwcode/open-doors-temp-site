class Story < ApplicationRecord
  include OtwArchive
  include OtwArchive::Request
  include Rails.application.routes.url_helpers
  include Item

  audited comment_required: true, associated_with: :author

  belongs_to :author
  belongs_to :coauthor, foreign_key: :coauthor_id, class_name: "Author"
  has_many :chapters

  def coauthor?
    coauthor.present?
  end

  def to_be_imported
    !(self.imported || self.do_not_import)
  end

  def as_json(options = {})
    hash = super(include: { chapters: { only: [:id, :title, :position, :text] } })
    hash.merge!(
      errors: item_errors,
      date: convert_date(date),
      updated: convert_date(updated),
      summaryLength: summary&.size,
      summaryTooLong: summary && summary.size > 1250,
      chapters: chapters.sort_by(&:position).map { |c|
        c.as_json(only: [:id, :title, :position])
          .merge!(
            title: (c.title.blank? ? "Chapter #{c.position}" : c.title),
            textLength: c.text.size,
            textTooLong: c.text.size > 510_000 # Same as Archive MAX_LENGTH
          ).except!(:content)
      }
    )
  end

  def to_work(archive_config, host)
    Request::Work.new(
      title,
      author.name,
      author.email,
      (coauthor.nil? ? "" : coauthor.name),
      (coauthor.nil? ? "" : coauthor.email),
      archive_config.collection_name,
      fandoms,
      warnings,
      characters,
      rating,
      relationships,
      language_code,
      categories,
      tags,
      "#{archive_config.stories_note}\n<br/><br/><p>--</p><br/>#{notes}",
      id,
      summary,
      chapters.map { |c| chapter_url(c, host: host) }
    )
  end
end
