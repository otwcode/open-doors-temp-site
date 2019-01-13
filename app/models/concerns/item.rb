# frozen_string_literal: true

module Item
  extend ActiveSupport::Concern
  include OtwArchive
  include OtwArchive::Request

  OK_STATUSES = %w[ok created already_imported found].freeze
  NOT_FOUND_STATUSES = ["not_found"].freeze
  ERROR_STATUSES = %w[unprocessable_entity bad_request].freeze

  def reset_flags
    Story.update_all(do_not_import: false, imported: false, ao3_url: nil)
    StoryLink.update_all(do_not_import: false, imported: false, ao3_url: nil)
    Author.update_all(do_not_import: false, imported: false)
  end

  def convert_date(date)
    date&.strftime("%Y-%m-%d")
  end

  def item_errors
    type = self.class.name.underscore.humanize(capitalize: false)
    item = self
    errors = []
    if item.summary && item.summary&.length > SUMMARY_LENGTH
      errors << "Summary for #{type} '#{item.title}' is too long (#{item.summary.length})"
    end
    if item.respond_to?(:chapters)
      item.chapters.map { |c|
        if c.text && c.text.length > CHAPTER_LENGTH
          errors << "Chapter #{c.position} in story '#{item.title}' is too long (#{c.text.length})"
        end
      }
    end
    if item.fandoms.blank?
      errors << "Fandom for story link '#{item.title}' is missing"
    end
    errors
  end

  def self.update_item(type, response)
    item = nil
    if type == :story
      item = Story.find_by_id(response[:original_id])
    elsif type == :bookmark
      item = StoryLink.find_by_id(response[:original_id])
    end

    if response[:status].in? OK_STATUSES
      response[:success] = true
      search_results = response.delete(:search_results)
      archive_url = search_results ? search_results[0]["archive_url"] : response[:archive_url]
      response[:ao3_url] = archive_url
      # TODO fix when AO3-5572 is fixed
      response[:messages] = [response[:messages]] if response[:messages].is_a?(String)
      if item.ao3_url != archive_url || (item.ao3_url == archive_url && !item.imported)
        response[:messages] << "Archive URL updated to #{archive_url}."
        item.update_attributes!(
          imported: true,
          ao3_url: archive_url,
          audit_comment: response[:messages].join(" ")
        )
      else
        response[:messages] << "Item is already imported at #{archive_url}."
      end
    elsif response[:status].in? NOT_FOUND_STATUSES
      if item.imported || item.ao3_url.present?
        response[:success] = false
        response[:messages] << "Item has been deleted or target site has changed."
        item.update_attributes!(
          imported: false,
          ao3_url: nil,
          audit_comment: response[:messages].join(" ")
        )
      else
        response[:success] = true
        response[:messages] << "Item is already marked as not imported."
      end
    elsif response[:status].in? ERROR_STATUSES
      response[:success] = false
      audit = Audited::Audit.new(
        auditable_id: item.id,
        auditable_type: item.class.name,
        associated_id: item.author.id,
        associated_type: item.author.class.name,
        comment: "#{response[:status].humanize}: #{response[:messages].join(' ')}".truncate(254)
      )
      audit.save!
    end
    response[:author_id] = item.author.id
    response[:messages] = response[:messages].reject { |m| m == "" }
    result = {}
    result[item.id] = response
    result
  end
end
