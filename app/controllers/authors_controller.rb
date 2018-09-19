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
      .map do |a|
      { 
        name: a.name, 
        imported: a.imported, 
        s_to_import: a.stories.where(imported: false).count, 
        l_to_import: a.story_links.where(imported: false).count 
      }
      end
      .group_by { |a| a[:name][0].upcase }
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
  # 
  # def api_index
  #   letter_authors, @letters = Author.with_stories_or_story_links
  #                                .alpha_paginate(params[:letter],
  #                                                bootstrap4: true,
  #                                                include_all: false,
  #                                                numbers: true,
  #                                                others: true
  #                                ) { |author| author.name.downcase }
  #   render json: letter_authors.paginate(page: params[:page], per_page: 30)
  # end
  
  def cable_event
    message = { message: "Imported #{params[:author_id]}" }
    ActionCable.server.broadcast 'imports_channel', message
    render json: message, content_type: "application/json"
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
        author.works_and_bookmarks(@client.config.archivist, @archive_config.collection_name, request.host_with_port)

      response = @client.import(works: works, bookmarks: bookmarks)

      works_responses = response[0]["works"]
      if works_responses.present?
        works_responses.each do |work_response|
          update_item(:story, work_response.symbolize_keys)
        end
      end

      bookmarks_responses = response[1] ? response[1]["bookmarks"] : response[0]["bookmarks"]
      if bookmarks_responses.present?
        bookmarks_responses.each do |bookmark_response|
          update_item(:bookmark, bookmark_response.symbolize_keys)
        end
      end
    end

    # Is the author now fully imported?
    response[0][:author_imported] = author.all_imported?

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
    author = Author.find(params[:author_id])

    works, bookmarks =
      author.works_and_bookmarks(@client.config.archivist, @archive_config.collection_name, request.host_with_port)

    response = @client.search(works: works, bookmarks: bookmarks)

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

    # Is the author now fully imported?
    response[0][:author_imported] = author.all_imported?

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
