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
      broadcast = { author_id: id, isImporting: true, message: "#{current_user&.name}: Starting import for #{author.name}" }
      ActionCable.server.broadcast 'imports_channel', broadcast

      response = author.import(@client, @archive_config.collection_name, request.host_with_port)

      message = "#{current_user&.name || 'Anonymous'}: Processed import for #{author.name} with status #{response[:status]}: #{response[:messages].join(' ')}"

      broadcast = {
        author_id: id,
        is_ok: ["ok"].include?(response[:status]),
        message: message,
        isImporting: false,
        response: response
      }
      ActionCable.server.broadcast 'imports_channel', broadcast
    rescue StandardError => e
      message = {
        author_id: id,
        is_ok: false,
        message: "#{current_user&.name}: Error importing #{author.name} with error: #{e.message}.",
        isImporting: false,
        response: response
      }
      ActionCable.server.broadcast 'imports_channel', message
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
    author = Author.find(params[:author_id])
    message = { author_id: author.id, message: "Checking #{author.name}" }
    ActionCable.server.broadcast 'imports_channel', message

    response = author.check(@client, @archive_config.collection_name, request.host_with_port)

    message = { author_id: author.id, message: "Checked #{author.name}. response: #{response}" }
    ActionCable.server.broadcast 'imports_channel', message

    render json: response, content_type: "text/json"
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
    import_config = OtwArchive::ImportConfig.new(api_settings[:url], api_settings[:key], "testy")
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
