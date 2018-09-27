class AuthorsController < ApplicationController
  require 'application_helper'

  include OtwArchive
  include OtwArchive::Request
  include Item

  def initialize
    archive_config = ArchiveConfig.archive_config
    api_settings = Rails.application.secrets[:ao3api][archive_config.host.to_sym]
    import_config = OtwArchive::ImportConfig.new(api_settings[:url], api_settings[:key], "testy")
    @client = OtwArchive::Client.new(import_config)
    super
  end

  def allLetters
    Author.all
      .map {|a|
        {
          name: a.name,
          imported: a.imported,
          s_to_import: a.stories.where(imported: false).count,
          l_to_import: a.story_links.where(imported: false).count
        }
      }.group_by {|a| a[:name][0].upcase}
  end

  def current_authors
    max = 30
    page = params[:page] || '1'
    letter = params[:letter] || 'A'
    all_current_authors = Author.select(:id, :name, :imported, :do_not_import).where("substr(upper(name), 1, 1) = '#{letter}'")
    @pages = (all_current_authors.size.to_f / max.to_f).ceil
    all_current_authors.limit(30).offset((page.to_i - 1) * 30)
  end

  def index
    @all_letters = allLetters
    @authors = current_authors
  end

  def import
    id = params[:author_id]
    author = Author.find(id)
    message = {author_id: id, message: "Starting import for #{author.name}"}
    ActionCable.server.broadcast 'imports_channel', message

    response = author.import(@client, @archive_config.collection_name, request.host_with_port)

    message = {
      author_id: id,
      has_error: ["ok"].include?(response[:status]),
      message: "Imported #{author.name}.",
      response: response
    }
    ActionCable.server.broadcast 'imports_channel', message

    render json: response, content_type: "application/json"
  end


  # Mark as imported (not currently in use)
  def mark
    respond_to :json
    author = Author.find(params[:author_id])
    imported_status = "set author to #{author.imported ? "" : "NOT "}imported."
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
    message = {author_id: id, message: "Checking #{author.name}"}
    ActionCable.server.broadcast 'imports_channel', message

    response = author.check(@client, @archive_config.collection_name, request.host_with_port)

    message = { author_id: id, message: "Checked #{author.name}. response: #{response}" }
    ActionCable.server.broadcast 'imports_channel', message

    render json: response, content_type: "text/json"
  end

  def dni
    respond_to :json
    author = Author.find(params[:author_id])
    imported_status = "set author to #{!author.do_not_import ? "NOT " : ""}allow importing."
    author.update_attributes!(do_not_import: !author.do_not_import, audit_comment: imported_status)
    response = []
    response << {status: :ok,
                 dni: author.do_not_import,
                 messages: ["Successfully #{imported_status}"]}

    if request.xhr?
      render json: response, content_type: "text/json"
    else
      @api_response = response[0][:messages]
    end
  end
end
