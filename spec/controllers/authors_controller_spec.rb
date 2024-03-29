# frozen_string_literal: true
require "rails_helper"
require "spec_helper"
require "webmock"
require "web_mock_helper"

describe AuthorsController, type: :controller do
  include WebMockHelper
  
  let!(:archive_config) { create(:archive_config) }
  let!(:author1) { create(:author_with_stories) }
  let!(:story1) { create(:story, author_id: author1.id, audit_comment: "Test") }

  setup do
    @controller = AuthorsController.new
  end
  
  before do
    mock_external
  end
  
  after do
    WebMock.reset!
  end

  it "renders the authors template with a list of letters and authors" do
    get :index
    letters = assigns(:letter_counts)
    expect(letters).to be_a Hash
    expect(letters.keys).to eq ["A"]
    authors = assigns(:authors)
    expect(authors).to be_a Array
    expect(authors[0][:name]).to eq author1.name
  end
  
  it "lists authors with stories and bookmarks" do
    get :author_letters
    expect(response.status).to be 200
    parsed_body = JSON.parse(response.body).symbolize_keys
    expect(parsed_body).to be_a Hash
    expect(parsed_body.keys).to eq [:A]
  end
  
  it "initiates an import for the given author" do
    post :import_author, params: { author_id: author1.id }
    expect(response.status).to be 200
    parsed_body = JSON.parse(response.body).symbolize_keys
    expect(parsed_body[:status]).to eq "Ok"
  end

  it "returns an error if the given author is not found" do
    post :import_author, params: { author_id: 9999999999 }
    expect(response.body).to include "Couldn't find Author"
  end
  
  it "returns an error if the given author is marked as do not import" do
    author = create(:author, do_not_import: true, audit_comment: "Test")
    post :import_author, params: { author_id: author.id }
    parsed_body = JSON.parse(response.body).symbolize_keys
    expect(parsed_body[:messages][0]).to eq "This author is set to do NOT import."
  end
end
