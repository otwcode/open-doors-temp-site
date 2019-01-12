# frozen_string_literal: true

class AuthorsController < ApplicationController
  require 'application_helper'

  include OtwArchive
  include OtwArchive::Request
  include Item

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
      broadcast_message("Starting import for #{author.name}", id, processing_status = "importing")

      response = author.import(@client, request.host_with_port)

      message = "Processed import for #{author.name} with status #{response[:status]}: #{response[:messages].join(' ')}"
      broadcast_message(message, id, response, processing_status = "imported")
    rescue StandardError => e
      broadcast_message("Error importing #{author.name} with error: #{e.message}.", id, response, processing_status = "")
      Rails.logger.error("\n-----------------\nERROR in import_author")
      Rails.logger.error(e.message)
      Rails.logger.error(response)
      Rails.logger.error("------------------")
    end
    render json: response, content_type: "application/json"
  end


  # Mark as imported (not currently in use)
  def mark
    respond_to :json
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
      broadcast_message("Checking #{author.name}", id, processing_status: "checking")

      response = author.check(@client, request.host_with_port)

      message = "Processed check for #{author.name} with status #{response[:status]}: #{response[:messages].join(' ')}"
      broadcast_message(message, id, response: response)
    rescue StandardError => e
      Rails.logger.error("\n-----------------\nError in authors_controller > check")
      Rails.logger.error(e)
      Rails.logger.error(e.backtrace.join("\n"))
      broadcast_message("Error checking #{author.name} with error: #{e.message}.", id, response: response)
    end
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

  def broadcast_message(message, id, processing_status: "", response: {})
    status = ["importing", "imported", "checking"].include? processing_status ? processing_status : ""
    status_hash = case status
                    when "importing"
                      { isImporting: true }
                    when "imported"
                      { isImported: true }
                    when "checking"
                      { isChecking: true }
                    else
                      { isImporting: false, isChecking: false }
                  end
    ok_status = if response.any? && response.has_key?(:success)
                  response[:success]
                else
                  false
                end
    broadcast = {
      author_id: id,
      is_ok: ok_status,
      message: "#{DateTime.now} - #{current_user&.name || 'Anonymous'}: #{message}",
      response: response
    }.merge!(status_hash)
    ActionCable.server.broadcast 'imports_channel', broadcast
  end

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
