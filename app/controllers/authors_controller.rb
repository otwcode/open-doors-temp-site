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
    works = author.stories.map { |s| story_to_work(s) }
    bookmarks = author.bookmarks.map { |b| bookmark_to_ao3(b, @client.config.archivist) }
    Rails.logger.info bookmarks.inspect
    response = @client.import(works: works, bookmarks: author.bookmarks)
    if request.xhr?
      render json: response, content_type: 'text/json'
    else
      @api_response = response[:messages]
    end
  end

  def mark
    respond_to :json
    author = Author.find(params[:author_id])
    author.imported = !author.imported
    response = []
    if author.save
      response << { status: :ok,
                    mark: author.imported,
                    messages: ["Successfully set author to #{author.imported ? "" : "NOT "}imported."] }
    else
      response << { status: :error,
                    mark: author.imported,
                    messages: ["Could not set author to #{!author.imported ? "" : "NOT "}imported."] }
    end
    render json: response, content_type: 'text/json'
  end

  def dni
    respond_to :json
    author = Author.find(params[:author_id])
    author.doNotImport = !author.doNotImport
    response = []
    if author.save
      response << { status: :ok,
                    dni: author.doNotImport,
                    messages: ["Successfully set author to #{author.doNotImport ? "NOT " : ""}allow importing"]}
    else
      response << { status: :error,
                    dni: author.doNotImport,
                    messages: ["Could not set author to #{!author.doNotImport ? "NOT " : ""}allow importing"]}
    end
    render json: response, content_type: 'text/json'
  end
end
