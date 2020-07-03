# encoding: utf-8
require 'net/http'
require 'logger'

module OtwArchive
  class HttpClient
    include Faraday

    API_PATH = "api/v2"

    def initialize(host_url, token, api_path = API_PATH)
      base_uri = "#{host_url}/#{api_path}"
      @conn = Faraday.new(base_uri, headers: { accept: "application/json" }) do |conn|
        conn.authorization :Token, token: token
        conn.headers["Content-Type"] = "application/json"

        conn.options[:open_timeout] = 300 # 5 minutes
        conn.options[:timeout] = 3_000 # 50 minutes
        conn.request :json

        conn.response :json, content_type: /\bjson$/

        conn.use FaradayMiddleware::FollowRedirects
        conn.adapter Faraday.default_adapter

        # Disable SSL certificate verification for Staging only
        if host_url.include?("test.archiveofourown.org")
          conn.ssl[:verify] = false
        end
      end
    end

    def post_request(path, request = {})
      log_request(request, path)

      begin
        response = @conn.post path, request.to_json

        log_raw_response(response, path)

        success = response.status < 400 && response.status >= 200
        reason_phrase = if response.reason_phrase.empty?
                          (success ? "Ok" : "Error")
                        else
                          response.reason_phrase
                        end

        body = if response.body.is_a?(String)
                 { messages: [response.body] }
               else
                 response.body&.symbolize_keys
               end

        {
          success: success,
          status: reason_phrase,
          body: body
        }
      rescue ClientError => e # Catch all Faraday's errors
        Rails.logger.error e.inspect
        {
          success: false,
          status: :error,
          body: { messages: [e.message] }
        }
      rescue StandardError => e
        Rails.logger.error e.inspect
        {
          success: false,
          status: :error,
          body: { messages: [e.message] }
        }
      end
    end

    private

    def log_raw_response(response, path)
      Rails.logger.info "\n----------START raw response FROM #{path}----------
                         success: #{response.success?}
                         reason_phrase: #{response.reason_phrase}
                         status: #{response.status}
                         headers: #{response.headers}
                        #{JSON.pretty_generate(response.body.as_json) unless response.body.nil?}"
    end

    def log_request(request, path)
      Rails.logger.info "\n----------START post_request TO #{path}----------
                        >>Request in post_request as_json:
                        \n#{JSON.pretty_generate(request.as_json)}
                        \n---------END post_request----------"
    end
  end # HttpClient
end # OtwArchive

