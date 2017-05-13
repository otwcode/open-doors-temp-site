class AuthorsController < ApplicationController
  require 'will_paginate/array'
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

  def index
    letter_authors, @letters = Author.with_stories_or_bookmarks
                                     .alpha_paginate(params[:letter],
                                                     bootstrap3: true,
                                                     include_all: false,
                                                     numbers: true,
                                                     others: true
                                     ) { |author| author.name.downcase }
    @authors = letter_authors.paginate(page: params[:page], per_page: 30)
  end

  def import
    respond_to :json
    author = Author.find(params[:author_id])

    works = author.stories.map { |s| story_to_work(s, @client.config.collection) }
    bookmarks = author.bookmarks.map { |b| bookmark_to_ao3(b, @client.config.archivist, @client.config.collection) }

    response = @client.import(works: works, bookmarks: bookmarks)
    works_responses = response[0]["works"]
    if works_responses.present?
      works_responses.each do |work_response|
        update_item(:story, work_response.symbolize_keys)
      end
    end
    bookmarks_responses = response[0]["bookmarks"]
    if bookmarks_responses.present?
      bookmarks_responses.each do |bookmark_response|
        update_item(:bookmark, bookmark_response.symbolize_keys)
      end
    end
    if request.xhr?
      render json: response, content_type: "text/json"
    else
      @api_response = response[0][:messages]
    end
  end

  def mark
    respond_to :json
    author = Author.find(params[:author_id])
    imported_status = "set author to #{author.imported ? "" : "NOT "}imported."
    author.update_attributes(imported: !author.imported, audit_comment: imported_status)
    response = []
    if author.save
      response << { status: :ok,
                    mark: author.imported,
                    messages: ["Successfully #{imported_status}"] }
    else
      response << { status: :error,
                    mark: author.imported,
                    messages: ["Could not  #{imported_status}"] }
    end
    if request.xhr?
      render json: response, content_type: "text/json"
    else
      @api_response = response[0][:messages]
    end
  end

  def dni
    respond_to :json
    author = Author.find(params[:author_id])
    imported_status = "set author to #{author.do_not_import ? "NOT " : ""}allow importing."
    author.update_attributes(do_not_import: !author.do_not_import, audit_comment: imported_status)
    response = []
    if author.save
      response << { status: :ok,
                    dni: author.do_not_import,
                    messages: ["Successfully #{imported_status}"] }
    else
      response << { status: :error,
                    dni: author.do_not_import,
                    messages: ["Could not #{imported_status}"] }
    end
    if request.xhr?
      render json: response, content_type: "text/json"
    else
      @api_response = response[0][:messages]
    end
  end
end
