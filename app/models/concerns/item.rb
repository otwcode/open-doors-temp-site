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

  def self.update_item(type, response)
    item = nil
    if type == :story
      item = Story.find_by_id(response[:original_id])
    elsif type == :bookmark
      item = StoryLink.find_by_id(response[:original_id])
    end

    if response[:status].in? OK_STATUSES
      response[:success] = true
      if item.ao3_url != response[:archive_url] || (item.ao3_url == response[:archive_url] && !item.imported)
        response[:messages] << "Archive URL updated to #{response[:archive_url]}."
        item.update_attributes!(
          imported: true,
          ao3_url: response[:archive_url],
          audit_comment: response[:messages].join(" ")
        )
      else
        response[:messages] << "Item is already imported at #{response[:archive_url]}."
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
    result = {}
    result[item.id] = response
    result
  end
end
