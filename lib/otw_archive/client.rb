# encoding: utf-8
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
      request_body = Request::ImportRequest.populate_from_config(@config, "", items_to_import[:works], items_to_import[:bookmarks])
      responses = []

      begin
        http = HttpClient.new(@config.archive_host, @config.token)

        items_to_import.symbolize_keys.each do |type, items|
           responses << http.post_request(type.to_s, request_body) unless items.blank?
        end
        Rails.logger.info responses
      rescue Exception => e
        Rails.logger.error e
        Rails.logger.error e.backtrace.join("\n")
        responses << { status: :error, messages: ["An exception occurred: #{e}"] }
      end
      responses
    end
  end # Client
end # OtwArchive
