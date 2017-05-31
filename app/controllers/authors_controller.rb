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
    letter_authors, @letters = Author.with_stories_or_story_links
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

    if author.do_not_import
      response = [
        {
          status: :unprocessable_entity,
          messages: [
            "This author is set to do NOT import."
          ],
          works: [],
          bookmarks: []
        }
      ]
    else
      works, bookmarks =
        author.works_and_bookmarks(@client.config.archivist, @site_config.collection_name, request.host_with_port)

      response = @client.import(works: works, bookmarks: bookmarks)
      works_responses = response[0]["works"]
      if works_responses.present?
        works_responses.each do |work_response|
          update_item(:story, work_response.symbolize_keys)
        end
      end

      bookmarks_responses = if response[1]
                              response[1]["bookmarks"]
                            else
                              response[0]["bookmarks"]
                            end
      if bookmarks_responses.present?
        bookmarks_responses.each do |bookmark_response|
          update_item(:bookmark, bookmark_response.symbolize_keys)
        end
      end
    end
    if request.xhr?
      render json: response, content_type: "text/json"
    else
      @api_response = response[0][:messages]
    end
  end

  # Mark as imported (not currently in use)
  def mark
    respond_to :json
    author = Author.find(params[:author_id])
    imported_status = "set author to #{author.imported ? "" : "NOT "}imported."
    author.update_attributes!(imported: !author.imported, audit_comment: imported_status)
    response = []
    response << { status: :ok,
                  mark: author.imported,
                  messages: ["Successfully #{imported_status}"] }
    if request.xhr?
      render json: response, content_type: "text/json"
    else
      @api_response = response[0][:messages]
    end
  end

  def check
    respond_to :json
    Rails.logger.info("Check author")
    author = Author.find(params[:author_id])
    imported_status = "checked status of author items."

    works, bookmarks =
      author.works_and_bookmarks(@client.config.archivist, @site_config.collection_name, request.host_with_port)

    response = @client.check(works: works, bookmarks: bookmarks)

    works_responses = response[0]["works"]
    if works_responses.present?
      works_responses.each do |work_response|
        update_item(:story, work_response.symbolize_keys)
      end
    end

    bookmarks_responses = if response[1]
                            response[1]["bookmarks"]
                          else
                            response[0]["bookmarks"]
                          end
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

  def dni
    respond_to :json
    author = Author.find(params[:author_id])
    imported_status = "set author to #{!author.do_not_import ? "NOT " : ""}allow importing."
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
end
