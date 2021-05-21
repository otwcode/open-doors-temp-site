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
    expect(response[:success]).to eq true
    expect(response[:messages][0]).to eq "At least one work was not imported. Please check individual work responses for further information."
    story1.destroy
    story2.destroy
  end

  describe "all_imported?" do
    let(:story) {Story.new(imported: false, do_not_import: false)}
    let(:story_link) { StoryLink.new(imported: false, do_not_import: false) }
    let(:imported_story) { Story.new(imported: true, do_not_import: false) }
    let(:imported_story_link) { StoryLink.new(imported: true, do_not_import: false) }
    let(:do_not_import_story) { Story.new(imported: false, do_not_import: true) }
    let(:do_not_import_story_link) { StoryLink.new(imported: false, do_not_import: true) }

    it "returns true if both stories and story links are empty" do
      imported_author = Author.new(stories: [], story_links: [])
      expect(imported_author.all_imported?).to eq true
    end
    it "returns true if all stories are imported or marked as do not import and story links are empty" do
      imported_author = Author.new(stories: [imported_story, do_not_import_story], story_links: [])
      expect(imported_author.all_imported?).to eq true
    end
    it "returns true if stories are empty and all story links are imported or marked as do not import" do
      imported_author = Author.new(stories: [], story_links: [imported_story_link, do_not_import_story_link])
      expect(imported_author.all_imported?).to eq true
    end
    it "returns false if only some stories are imported or marked as do not import and story links are empty" do
      imported_author = Author.new(stories: [story, imported_story], story_links: [])
      expect(imported_author.all_imported?).to eq false
    end
    it "returns false if stories are empty and only some story links are imported or marked as do not import" do
      imported_author = Author.new(stories: [], story_links: [story_link, do_not_import_story_link])
      expect(imported_author.all_imported?).to eq false
    end
    it "returns false if no stories and no story links are imported or marked as do not import" do
      imported_author = Author.new(stories: [story], story_links: [story_link])
      expect(imported_author.all_imported?).to eq false
    end
  end
end
