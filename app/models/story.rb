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

  def item_errors
    errors = []
    if summary.length > 1250
      errors << "Summary for story '#{title}' is too long (#{summary.length})"
    end
    chapters.map { |c|
      if c.text.length > 510_000
        errors << "Chapter #{c.position} in story '#{title}' is too long (#{c.text.length})"
      end
    }
    errors
  end

  def as_json(options = {})
    hash = super(include: { chapters: { only: [:id, :title, :position, :text] } })
    hash.merge!(
      errors: item_errors,
      date: date.strftime("%Y-%m-%d"),
      updated: date.strftime("%Y-%m-%d"),
      summaryLength: summary.size,
      summaryTooLong: summary.size > 1250,
      chapters: chapters.map { |c|
        c.as_json(only: [:id, :title, :position])
          .merge!(
            title: (c.title.blank? ? "Chapter #{c.position}" : c.title),
            textLength: c.text.size,
            textTooLong: c.text.size > 510_000 # Same as Archive MAX_LENGTH
          ).except!(:content)
      }
    )
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
