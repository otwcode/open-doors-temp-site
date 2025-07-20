# frozen_string_literal: true

require 'rails_helper'
require "webmock"
require "web_mock_helper"

describe Author, type: :model do
  include WebMockHelper

  let!(:archive_config) { create(:archive_config, archivist: "testy") }
  let!(:author1) { create(:author_with_stories, audit_comment: "Test") }


  before do
    mock_external
  end

  after do
    WebMock.reset!
  end

  it "returns the remote error message if there is an authorisation problem" do
    import_config = OtwArchive::ImportConfig.new("unauthorized", 999, archive_config)
    client = OtwArchive::Client.new(import_config)
    response = author1.import(client, "test")
    expect(response[:status]).to eq "Unauthorized"
    expect(response[:messages][0]).to eq "HTTP Token: Access denied.\n"
  end

  it "returns the remote error message if there is an authentication problem" do
    archive_config = create(:archive_config, archivist: "not_archivist")
    import_config = OtwArchive::ImportConfig.new("forbidden", 333, archive_config)
    client = OtwArchive::Client.new(import_config)
    response = author1.import(client, "test")
    expect(response[:status]).to eq "Forbidden"
    expect(response[:messages][0]).to eq "The \"archivist\" field must specify the name of an Archive user with archivist privileges."
  end

  it "returns a success if there is a mix of created and found items" do
    story1 = Story.new(id: 10, author_id: author1.id, audit_comment: "Test1")
    story2 = Story.new(id: 20, author_id: author1.id, audit_comment: "Test2")
    story1.save! && story2.save!
    archive_config = create(:archive_config, archivist: "archivist")
    import_config = OtwArchive::ImportConfig.new("multi_works", 123, archive_config)
    client = OtwArchive::Client.new(import_config)
    response = author1.import(client, "test")
    puts response
    expect(response[:status]).to eq "Bad Request"
    expect(response[:success]).to eq false
    expect(response[:messages][0]).to eq "At least one work was not imported. Please check individual work responses for further information."
    story1.destroy
    story2.destroy
  end

  describe "all_imported?" do
    it "returns true if both stories and story links are empty" do
      author = create(:author)
      expect(Author.all_imported.include?(author.id)).to eq true
    end
    it "returns true if all stories are imported or marked as do not import and story links are empty" do
      author = create(:author)
      imported_story = create(:story, author_id: author.id, imported: true, audit_comment: "Test")
      do_not_import_story = create(:story, author_id: author.id, do_not_import: true, audit_comment: "Test")
      expect(Author.all_imported.include?(author.id)).to eq true
    end
    it "returns true if stories are empty and all story links are imported or marked as do not import" do
      author = create(:author)
      imported_story_link = create(:story_link, author_id: author.id, imported: true, audit_comment: "Test")
      do_not_import_story_link = create(:story_link, author_id: author.id, do_not_import: true, audit_comment: "Test")
      expect(Author.all_imported.include?(author.id)).to eq true
    end
    it "returns true if author has no stories with chapters" do
      author = create(:author)
      story = create(:story_no_chapters, author_id: author.id, audit_comment: "Test")
      expect(Author.all_imported.include?(author.id)).to eq true
    end
    it "returns true if author has imported story and a story with no chapters" do
      author = create(:author)
      imported_story = create(:story, author_id: author.id, imported: true, audit_comment: "Test")
      story_no_chapters = create(:story_no_chapters, author_id: author.id, audit_comment: "Test")
      expect(Author.all_imported.include?(author.id)).to eq true
    end
    it "returns false if only some stories are imported or marked as do not import and story links are empty" do
      author = create(:author)
      story = create(:story, author_id: author.id, audit_comment: "Test")
      imported_story = create(:story, author_id: author.id, imported: true, audit_comment: "Test")
      expect(Author.all_imported.include?(author.id)).to eq false
    end
    it "returns false if stories are empty and only some story links are imported or marked as do not import" do
      author = create(:author)
      story_link = create(:story_link, author_id: author.id, audit_comment: "Test")
      imported_story_link = create(:story_link, author_id: author.id, imported: true, audit_comment: "Test")
      expect(Author.all_imported.include?(author.id)).to eq false
    end
    it "returns false if no stories and no story links are imported or marked as do not import" do
      author = create(:author)
      story = create(:story, author_id: author.id, audit_comment: "Test")
      story_link = create(:story_link, author_id: author.id, audit_comment: "Test")
      expect(Author.all_imported.include?(author.id)).to eq false
    end
  end

  it 'returns too many item errors' do
    stub_const("NUMBER_OF_ITEMS", 4)
    author = create(:author, name: "testy")
    5.times {
      story = create(:story, author_id: author.id, audit_comment: "Test")
      story_link = create(:story_link, author_id: author.id, audit_comment: "Test")
    }
    errors = Author.all_errors(author.id.to_s)
    expect(errors.key?(author.id)).to eq true
    expect(errors[author.id].include?("Author 'testy' has 5 stories - the Archive can only import 4 at a time")).to eq true
    expect(errors[author.id].include?("Author 'testy' has 5 bookmarks - the Archive can only import 4 at a time")).to eq true
  end

  it 'returns author has no stories with chapters errors' do
    author = create(:author, name: "testy")
    story = create(:story_no_chapters, author_id: author.id, title: "title", audit_comment: "Test")
    errors = Author.all_errors(author.id.to_s)
    expect(errors.key?(author.id)).to eq true
    expect(errors[author.id].include?("Author 'testy' has no stories with chapters")).to eq true
  end
end
