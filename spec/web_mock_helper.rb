# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

module WebMockHelper
  # Let the test get at external sites, but stub out anything containing certain keywords
  def mock_external
    # WebMock.allow_net_connect!
    # 
    # Failures
    WebMock.stub_request(:post, "https://unauthorized/api/v2/works")
           .to_return(status: [403, "Unauthorized"], body: "HTTP Token: Access denied.\n")

    # Successes
    WebMock.stub_request(:post, "http://localhost:3000/api/v2/works")
           .with(headers: { 'Authorization' => 'Token token="123"', 'Content-Type' => 'application/json' })
           .to_return(status: 200, body: "{}", headers: { 'Content-Type' => 'application/json' })

    WebMock.stub_request(:post, "https://forbidden/api/v2/works")
           .with(headers: { 'Authorization' => 'Token token="333"' })
           .to_return(status: [401, "Forbidden"],
                      body: JSON.generate(
                        status: "forbidden",
                        messages: ["The \"archivist\" field must specify the name of an Archive user with archivist privileges."],
                        works: []
                      ), headers: { 'Content-Type' => 'application/json' })
  end
end
