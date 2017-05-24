class ItemsController < ApplicationController
  require 'application_helper'

  include OtwArchive
  include OtwArchive::Request
  include ApplicationHelper

  def initialize
    active_api   = Rails.application.secrets[:ao3api][:active]
    api_settings = Rails.application.secrets[:ao3api][active_api.to_sym]
    import_config = OtwArchive::ImportConfig.new("http://" + api_settings[:url], api_settings[:key], "testy")
    @client = OtwArchive::Client.new(import_config)
    super
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
              story_to_work(item, @site_config.collection_name)
            ]
          }
        else
          {
            bookmarks: [
              storylink_to_bookmark(item, @client.config.archivist, @site_config.collection_name)
            ]
          }
        end

      response = @client.import(item_request)

      Rails.logger.info("response: #{response}")

      item_response = response[0][ao3_type][0]
      final_response[0][ao3_type] = [update_item(type.to_sym, item_response.symbolize_keys)]
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

    puts "item import: #{final_response.inspect}"

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

    imported_status = "set #{type} '#{item.title}' by #{author.name} to #{item.do_not_import ? "NOT " : ""}allow importing."
    item.update_attributes!(do_not_import: !item.do_not_import, audit_comment: imported_status)

    response = []
    response << { status: :ok,
                  dni: item.do_not_import,
                  messages: ["Successfully #{imported_status}"] }
    if request.xhr?
      render json: response, content_type: "text/json"
    else
      @api_response = response[0][:messages]
    end
  end

  def audit
    # respond_to :json
    type = params[:type]
    id = params[:id]

    item = find_item(id, type)

    audit = item.audits.map { |audit| "#{audit.created_at} - [#{audit.remote_address}] #{CGI.escapeHTML(audit.comment)}<br/>" }.join()

    puts audit
    
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
