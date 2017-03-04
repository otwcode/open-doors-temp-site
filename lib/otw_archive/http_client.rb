# encoding: utf-8
require 'net/http'
require 'logger'

module OtwArchive
  class HttpClient
    include Faraday

    API_PATH = "api/v1"

    def initialize(host_url, token, api_path = API_PATH)
      base_uri = "#{host_url}/#{api_path}"
      Rails.logger.info base_uri
      @conn = Faraday.new(base_uri, headers: {accept: 'application/json'}) do |conn|
        conn.authorization :Token, token: token
        conn.headers['Content-Type'] = 'application/json'

        conn.options[:open_timeout] = 2000
        conn.options[:timeout] = 5000
        conn.request :json

        conn.response :json, :content_type => /\bjson$/

        conn.use FaradayMiddleware::FollowRedirects
        conn.adapter Faraday.default_adapter
      end
    end

    def post_request(path, request = {})
      Rails.logger.info "\n#{request.to_json}"

      response = @conn.post path, request.to_json

      Rails.logger.info response.status
      Rails.logger.info response.headers
      Rails.logger.info response.body unless response.body.nil?
      response.body
    end
  end # HttpClient
end #OtwArchive

