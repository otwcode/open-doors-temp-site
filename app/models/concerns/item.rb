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
    errors << "Summary for #{type} '#{item.title}' is too long (#{item.summary.length})" if item.summary && item.summary&.length > SUMMARY_LENGTH
    if item.respond_to?(:chapters)
      item.chapters.map { |c|
        errors << "Chapter #{c.position} in story '#{item.title}' is too long (#{c.text.length})" if c.text && c.text.length > CHAPTER_LENGTH
      }
    end
    errors << "Fandom for story link '#{item.title}' is missing" if item.fandoms.blank?
    errors
  end

  def self.items_responses(ao3_response, check = false)
    response = {}
    has_success = ao3_response[0][:success]

    bookmarks_responses = ao3_response[1] ? ao3_response[1][:body][:bookmarks] : ao3_response[0][:body][:bookmarks]

    response[:bookmarks] = update_items(bookmarks_responses, :bookmark)

    response[:works] = ao3_response[0][:body][:works] ? update_items(ao3_response[0][:body][:works], :story) : []
    response[:messages] = if check && ao3_response[0][:body][:search_results]
                            ao3_response[0][:body][:search_results][:message]
                          else
                            ao3_response[0][:body][:messages]
                          end
    response[:status] = ao3_response[0][:status] || "ok"
    response[:success] = has_success

    # Copy the author id to the main response object to pass information to the author UI as well
    all_items = !response[:works].empty? ? response[:works] : response[:bookmarks]
    response[:author_id] = all_items.first[1][:author_id] unless all_items.empty?

    response
  end

  def self.update_item(type, response)
    item = nil
    if type == :story
      item = Story.find_by_id(response[:original_id])
    elsif type == :bookmark
      item = StoryLink.find_by_id(response[:original_id])
    end

    # Add a synthetic `type` field for use in the broadcast
    class << item
      attr_accessor :type
    end

    if response[:status].in? OK_STATUSES
      response[:success] = true
      search_results = response.delete(:search_results)
      if search_results
        archive_url = search_results[0]["archive_url"]
        messages = [search_results[0]["message"]]
      else
        archive_url = response[:archive_url]
        messages = response[:messages]
      end
      response[:ao3_url] = archive_url
      response[:messages] = messages
      if item.ao3_url != archive_url || (item.ao3_url == archive_url && !item.imported)
        response[:messages] << "Archive URL updated to #{archive_url}."
        response[:imported] = true
        item.update_attributes!(
          imported: true,
          ao3_url: archive_url,
          audit_comment: response[:messages][0],
          type: type
        )
        Rails.logger.info(item.inspect)
      else
        response[:messages] << "Item is already imported at #{archive_url}."
        response[:imported] = true
      end
    elsif response[:status].in? NOT_FOUND_STATUSES
      if item.imported || item.ao3_url.present?
        response[:success] = false
        response[:messages] << "Item has been deleted or target site has changed."
        response[:imported] = false
        item.update_attributes!(
          imported: false,
          ao3_url: nil,
          audit_comment: response[:messages][0],
          type: type
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
        comment: "#{response[:status].humanize}: #{response[:messages][0]}".truncate(254)
      )
      audit.save!
    end
    # Update author in case this means it's fully imported
    response[:author_id] = item.author.id
    item.author.update_attributes!(
      imported: item.author.items_all_imported?
    )

    response[:messages] = response[:messages].reject { |m| m == "" }
    result = {}
    result[item.id] = response
    result
  end

  def self.update_items(items_responses, type)
    responses = {}
    if items_responses.present?
      items_responses.each do |item_response|
        update = Item.update_item(type, item_response.symbolize_keys)
        Rails.logger.info(update)
        responses.merge!(update)
      end
    end
    responses
  end
end
