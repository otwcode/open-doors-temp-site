class ItemsController < ApplicationController
  require 'application_helper'

  include OtwArchive
  include OtwArchive::Request
  include Item
  include ApplicationHelper

  def initialize
    load_config
    api_settings = Rails.application.secrets[:ao3api][@archive_config.host.to_sym]
    import_config = OtwArchive::ImportConfig.new(api_settings[:url], api_settings[:key], @archive_config)
    @client = OtwArchive::Client.new(import_config)
    super
  end

  def get_by_author
    author = Author.find(params[:author_id])
    render json: author.all_items_as_json
  end

  def import
    type = params[:type]
    id = params[:id]
    ao3_type = type == "story" ? "works" : "bookmarks"
    item = find_item(id, type)
    response = [{}]

    begin
      if !item.do_not_import && !item.author.do_not_import
        item_request = {}
        item_request[ao3_type.to_sym] =
          if type == "story"
            [item.to_work(@archive_config, request.host_with_port)]
          else
            [item.to_bookmark(@archive_config)]
          end

        ApplicationHelper.broadcast_message(
          "Starting individual import for #{type} id #{id}",
          id,
          current_user,
          processing_status: "importing",
          type: type)

        ao3_response = @client.import(item_request)
        response = Item.items_responses(ao3_response)

        # Status on the work object is more helpful
        status = if response[:works][id]
                   response[:works][id][:status]
                 else
                   response[:status]
                 end

        processing_status = if response[ao3_type.to_sym] && response[ao3_type.to_sym][id]
                              response[ao3_type.to_sym][id][:imported] ? "imported" : "none"
                            else
                              "none"
                            end

        ApplicationHelper.broadcast_message(
          "Processed individual import for #{type} id #{id} with status: '#{status}' ",
          id,
          current_user,
          processing_status: processing_status,
          response: response,
          type: type)

      else
        response[ao3_type] = [
          {
            status: :unprocessable_entity,
            original_id: item.id,
            messages: [
              if item.do_not_import
                "This #{type} is set to 'do NOT import'."
              elsif item.author.do_not_import
                "The author of this #{type} is set to 'do NOT import'."
              end
            ]
          }
        ]
      end

    rescue StandardError => e
      log_error(e, "items_controller > import_item", response)
      ApplicationHelper.broadcast_message(
        "Error importing #{item.title} with error: #{e.message}.",
        id,
        current_user,
        response: response,
        processing_status: "none",
        type: type)
    end
    # Is the author now fully imported?
    response[:author_imported] = item.author.all_imported?

    Rails.logger.info("-------- items_controller > import response ------")
    Rails.logger.info(JSON.pretty_generate(response.as_json))

    render json: response, content_type: 'application/json'
  end

  # def mark
  #   respond_to :json
  #   type = params[:type]
  #   id = params[:id]
  #
  #   item = find_item(id, type)
  #   author = item.author
  #
  #   imported_status = "set #{type} '#{item.title}' by #{author.name} to #{item.imported ? "" : "NOT "}imported."
  #   item.update_attributes!(imported: !item.imported, audit_comment: imported_status)
  #
  #   response = []
  #   response << { status: :ok,
  #                 mark: item.imported,
  #                 messages: ["Successfully #{imported_status}"] }
  #
  #
  #   # Is the author now fully imported?
  #   response[0][:author_imported] = item.author.all_imported?
  #
  #   if request.xhr?
  #     render json: response, content_type: "text/json"
  #   else
  #     @api_response = response[0][:messages]
  #   end
  # end

  def dni
    type = params[:type]
    id = params[:id]

    item = find_item(id, type)
    author = item.author

    imported_status = "set #{type} '#{item.title}' by #{author.name} to #{item.do_not_import ? "" : "NOT "}allow importing."
    item.update_attributes!(do_not_import: !item.do_not_import, audit_comment: imported_status)

    response = []
    response << { status: :ok,
                  dni: item.do_not_import,
                  messages: ["Successfully #{imported_status}"] }

    # Is the author now fully imported?
    response[0][:author_imported] = author.all_imported?

    if request.xhr?
      render json: response, content_type: "text/json"
    else
      @api_response = response[0][:messages]
    end
  end

  def check
    type = params[:type]
    id = params[:id]
    ao3_type = type == "story" ? "works" : "bookmarks"

    item = find_item(id, type)
    response = [{}]

    begin
      item_request = {}
      item_request[ao3_type.to_sym] =
        if type == "story"
          [item.to_work(@archive_config, request.host_with_port)]
        else
          [item.to_bookmark(@archive_config)]
        end

      ApplicationHelper.broadcast_message(
        "Starting individual check for #{type} id #{id}",
        id,
        current_user,
        processing_status: "checking",
        type: type)

      ao3_response = @client.search(item_request)
      response = Item.items_responses(ao3_response)

      # Status on the work object is more helpful
      status = if response[:works][id]
                 response[:works][id][:status]
               else
                 response[:status]
               end

      processing_status = response[ao3_type.to_sym][id][:imported] ? "imported" : "none"
      ApplicationHelper.broadcast_message(
        "Processed individual check for #{type} id #{id} with status: '#{status}' ",
        id,
        current_user,
        processing_status: processing_status,
        response: response,
        type: type)

    rescue StandardError => e
      log_error(e, "items_controller > import_item", response)
      ApplicationHelper.broadcast_message(
        "Error importing #{item.title} with error: #{e.message}.",
        id,
        current_user,
        response: response,
        processing_status: "none",
        type: type)
    end
    # Is the author now fully imported?
    response[:author_imported] = item.author.all_imported?

    Rails.logger.info("-------- items_controller > check response ------")
    Rails.logger.info(JSON.pretty_generate(response.as_json))

    render json: response, content_type: 'application/json'
  end

  def audit
    # respond_to :json
    type = params[:type]
    id = params[:id]
    item = find_item(id, type)
    audit = item.audits.map { |audit| "#{audit.created_at} - [#{audit.remote_address}] #{CGI.escapeHTML(audit.comment)}<br/>" }.join()

    render json: audit, content_type: "text/html"
  end

  protected

  def find_item(id, type)
    if type == "story"
      Story.find(id)
    else
      StoryLink.find(id)
    end
  end
end
