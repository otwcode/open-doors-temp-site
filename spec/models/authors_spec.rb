# frozen_string_literal: true

require 'rails_helper'
require "webmock"
require "web_mock_helper"

describe Author, type: :model do
  include WebMockHelper
  
  let!(:author1) { create(:author_with_stories, audit_comment: "Test") }
  let(:story1) { create(:story, author_id: author1.id, audit_comment: "Test") }

  before do
    mock_external
  end

  after do
    WebMock.reset!
  end

  # it "imports a single author and its items" do
  #   import_config = OtwArchive::ImportConfig.new("localhost:3000", "e1b6298a6209dd65e5df95b83b10c0f1", "ariana_paris")
  #   client = OtwArchive::Client.new(import_config)
  #   response = author1.import(client, "testing_collection", "localhost:3000")
  #   # expect(response[:status]).to eq ""
  #   expect(response[:messages]).to eq "ok"
  # end

  it "returns the remote error message if there is an authorisation problem" do
    import_config = OtwArchive::ImportConfig.new("unauthorized", 999, "testy")
    client = OtwArchive::Client.new(import_config)
    response = author1.import(client, "testing_collection", "test")
    expect(response[:status]).to eq "Unauthorized"
    expect(response[:messages][0]).to eq "HTTP Token: Access denied.\n"
  end

  it "returns the remote error message if there is an authentication problem" do
    import_config = OtwArchive::ImportConfig.new("forbidden", 333, "not_archivist")
    client = OtwArchive::Client.new(import_config)
    response = author1.import(client, "testing_collection", "test")
    expect(response[:status]).to eq "Forbidden"
    expect(response[:messages][0]).to eq "The \"archivist\" field must specify the name of an Archive user with archivist privileges."
  end

end
