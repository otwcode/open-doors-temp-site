# frozen_string_literal: true

class AuthorsController < ApplicationController
  require 'application_helper'

  include OtwArchive
  include OtwArchive::Request
  include Item
  include ApplicationHelper

  # Prevent unhandled errors from returning the normal HTML page
  rescue_from StandardError, with: :render_standard_error_response

  def initialize
    super
    @client ||= otw_client
  end

  def index
    @all_letters ||= Author.all_letters
  end

  def author_letters
    render json: Author.all_letters, content_type: "application/json"
  end

  def authors
    render json: current_authors, content_type: "application/json"
  end

  def import_author
    id = params[:author_id]
    author = Author.find(id)
    response = {}
    begin
      ApplicationHelper.broadcast_message(
        "Starting import for #{author.name}",
        id,
        current_user,
        processing_status: "importing")

      response = author.import(@client, request.host_with_port)

      message = "Processed import for #{author.name} with status #{response[:status]}: #{response[:messages].join(' ')}"
      processing_status = response[:author_imported] ? "imported" : "none"
      ApplicationHelper.broadcast_message(message, id, current_user, response: response, processing_status: processing_status)
    rescue StandardError => e
      log_error(e, "authors_controller > import_author", response)
      ApplicationHelper.broadcast_message(
        "Error importing #{author.name} with error: #{e.message}.",
        id,
        current_user,
        response: response,
        processing_status: "none")
    end
    Rails.logger.info("-------- authors_controller > import response ------")
    Rails.logger.info(response)
    render json: response, content_type: "application/json"
  end


  # Mark as imported (not currently in use)
  def mark
    author = Author.find(params[:author_id])
    imported_status = "set author to #{author.imported ? '' : 'NOT '}imported."
    author.update_attributes!(imported: !author.imported, audit_comment: imported_status)
    response = []
    response << {
      status: :ok,
      mark: author.imported,
      messages: ["Successfully #{imported_status}"]
    }

    # Is the author now fully imported?
    response[0][:author_imported] = author.all_imported?

    if request.xhr?
      render json: response, content_type: "text/json"
    else
      @api_response = response[0][:messages]
    end
  end

  def check
    id = params[:author_id]
    author = Author.find(id)
    response = {}
    begin
      ApplicationHelper.broadcast_message("Checking #{author.name}", id, current_user, processing_status: "checking")

      response = author.check(@client, request.host_with_port)

      message = "Processed check for #{author.name} with status #{response[:status]}: #{response[:messages].join(' ')}"
      ApplicationHelper.broadcast_message(message, id, current_user, response: response)
    rescue StandardError => e
      log_error(e, "authors_controller > check", response)
      ApplicationHelper.broadcast_message(
        "Error checking #{author.name} with error: #{e.message}.",
        id,
       current_user,
        response: response,
        type: "author")
    end
    Rails.logger.info("-------- authors_controller > check response ------")
    Rails.logger.info(response)
    render json: response, content_type: "application/json"
  end

  def dni
    respond_to :json
    author = Author.find(params[:author_id])
    imported_status = "set author to #{!author.do_not_import ? 'NOT ' : ''}allow importing."
    author.update_attributes!(do_not_import: !author.do_not_import, audit_comment: imported_status)
    response = []
    response << { status: :ok,
                  dni: author.do_not_import,
                  messages: ["Successfully #{imported_status}"] }

    if request.xhr?
      render json: response, content_type: "text/json"
    else
      @api_response = response[0][:messages]
    end
  end

  private

  def otw_client
    archive_config = ArchiveConfig.archive_config
    api_settings = Rails.application.secrets[:ao3api][archive_config.host.to_sym]
    import_config = OtwArchive::ImportConfig.new(api_settings[:url], api_settings[:key], archive_config = archive_config)
    OtwArchive::Client.new(import_config)
  end

  def current_authors
    max = 30
    page = params[:page] || '1'
    letter = params[:letter] || 'A'
    all_current_authors = Author.by_letter_with_items(letter)
    @pages = (all_current_authors.size.to_f / max.to_f).ceil
    all_current_authors[(page.to_i - 1) * 30, 30]
  end
end
