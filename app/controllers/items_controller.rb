class ItemsController < ApplicationController
  require 'application_helper'

  include OtwArchive
  include OtwArchive::Request
  include Item

  def initialize
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
    respond_to :json
    type = params[:type]
    id = params[:id]
    ao3_type = type == "story" ? "works" : "bookmarks"
    final_response = [{}] # Needs to be the same shape as the response for authors

    item = find_item(id, type)

    if !item.do_not_import && !item.author.do_not_import
      item_request =
        if type == "story"
          {
            works: [
              item.to_work(@archive_config, request.host_with_port)
            ]
          }
        else
          {
            bookmarks: [
              item.to_bookmark(@archive_config)
            ]
          }
        end

      response = @client.import(item_request)

      if response[0]["status"].in? ["ok", "created"]
        item_response = response[0][ao3_type]
        final_response[0][ao3_type] = [update_item(type.to_sym, item_response.symbolize_keys)]
      else
        Rails.logger.error(">>> Error returned from remote API:\n #{item_response}")

        final_response[0][ao3_type] = response
        final_response[0][ao3_type][0].merge!(original_id: item.id)
      end

    else

      final_response[0][ao3_type] = [
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

    # Is the author now fully imported?
    final_response[0][:author_imported] = item.author.all_imported?

    render json: final_response, content_type: 'text/json'
  end

  def mark
    respond_to :json
    type = params[:type]
    id = params[:id]

    item = find_item(id, type)
    author = item.author

    imported_status = "set #{type} '#{item.title}' by #{author.name} to #{item.imported ? "" : "NOT "}imported."
    item.update_attributes!(imported: !item.imported, audit_comment: imported_status)

    response = []
    response << { status: :ok,
                  mark: item.imported,
                  messages: ["Successfully #{imported_status}"] }


    # Is the author now fully imported?
    response[0][:author_imported] = item.author.all_imported?

    if request.xhr?
      render json: response, content_type: "text/json"
    else
      @api_response = response[0][:messages]
    end
  end

  def dni
    respond_to :json
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
    respond_to :json
    type = params[:type]
    id = params[:id]
    ao3_type = type == "story" ? "works" : "bookmarks"
    final_response = [{}] # Needs to be the same shape as the response for authors

    item = find_item(id, type)

    item_request =
      if type == "story"
        {
          works: [
            item.to_work(@archive_config, request.host_with_port)
          ]
        }
      else
        {
          bookmarks: [
            item.to_bookmark(@archive_config)
          ]
        }
      end

    response = @client.search(item_request)

    Rails.logger.info("response: #{response}")

    item_response = response[0][ao3_type][0]
    final_response[0][ao3_type] = [update_item(type.to_sym, item_response.symbolize_keys)]

    render json: final_response, content_type: 'text/json'
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
