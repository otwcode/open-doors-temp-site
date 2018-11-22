# frozen_string_literal: true

require 'logger'

module OtwArchive
  class Client
    include OtwArchive::Request

    attr_reader :config

    def initialize(import_config)
      @config = import_config
    end

    # Items = { works: [array of Work], bookmarks: [array of Bookmark]}
    def import(items_to_import = {})
      request_body = Request::ImportRequest.populate_from_config(
        @config,
        items_to_import[:works],
        items_to_import[:bookmarks]
      )
      responses = []

      begin
        @http ||= HttpClient.new(@config.archive_host, @config.token)

        items_to_import.symbolize_keys.each do |type, items|
          next if items.blank?

          responses << @http.post_request(type.to_s, request_body)
        end
        
        Rails.logger.info "\n>>> Processed import responses: \n#{JSON.pretty_generate(responses.as_json)}"
      rescue StandardError => e
        Rails.logger.error "\n>>> Error: #{e}"
        Rails.logger.error e.backtrace.join("\n")
        resp = []
        resp[:success] = false
        resp[:status] = :error
        resp[:messages] = ["An exception occurred: #{e}"]
        responses << resp
      end
      responses.map(&:symbolize_keys)
    end

    def search(items_to_check = {})
      responses = []
      items_to_check.symbolize_keys.each do |type, items|
        next if items.blank?

        request_body = if type == :works
                         Request::WorkSearchRequest.new(items.map { |w| { id: w.id, url: w.chapter_urls.first } } )
                       else
                         Request::BookmarkSearchRequest.new(@config.archivist, items)
                       end

        begin
          @http ||= HttpClient.new(@config.archive_host, @config.token)
          resp = @http.post_request("#{type}/search", request_body)

          resp[:body][:messages] << resp[:status] if resp[:body][:messages].all? { |m| m == "" }
          resp[:body][:messages] = resp[:body][:messages].reject { |m| m == "" }

          responses << resp
        rescue StandardError => e
          Rails.logger.error "\n>>> Error: #{e}"
          Rails.logger.error e.backtrace.join("\n")
          resp = []
          resp[:success] = false
          resp[:status] = :error
          resp[:messages] = ["An exception occurred: #{e}"]
          responses << resp
        end
      end
      Rails.logger.info "\n>>> Search responses: \n#{JSON.pretty_generate(responses.as_json)}"
      responses
    end
  end # Client
end # OtwArchive
