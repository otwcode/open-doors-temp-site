# frozen_string_literal: true

require 'rails_helper'

describe Story, type: :model do

  let!(:author1) { create(:author_with_stories, audit_comment: "Test") }
  let(:story1) { create(:story, author_id: author1.id, notes: "Original Notes", language_code: "de", audit_comment: "Test") }
  let(:story_no_notes) { create(:story, author_id: author1.id, audit_comment: "Test") }

  it 'converts a story with all fields correctly' do
    config = create(:archive_config, stories_note: "Story note")
    work = story1.to_work(config, "test")
    expect(work.notes).to eq "Story note\n<br/><br/><p>--</p><br/>Original Notes"
    expect(work.language_code).to eq "de"
  end

  it 'doesn’t include a separator if no notes are present' do
    config = create(:archive_config, stories_note: "Story note")
    work = story_no_notes.to_work(config, "test")
    expect(work.notes).to eq "Story note\n"
  end

  it 'returns a summary too long error in json object' do
    stub_const("SUMMARY_LENGTH", 4)
    story = Story.new(
      title: "title",
      fandoms: "Foo",
      summary: "Longer than 4 characters",
      chapters: [Chapter.new(text: "some text")])
    expect(story.as_json[:errors]).to eq ["Summary for story 'title' is too long (24)"]
  end

  it 'returns a chapter text too long error in json object' do
    stub_const("CHAPTER_LENGTH", 4)
    story = Story.new(
      title: "title",
      fandoms: "Foo",
      chapters: [Chapter.new(position: 1, text: "some text")])
    expect(story.as_json[:errors]).to eq ["Chapter 1 in story 'title' is too long (9)"]
  end

  it 'returns a fandom is missing error in json object' do
    story = Story.new(
      title: "title")
    expect(story.as_json[:errors]).to eq ["Fandom for story link 'title' is missing"]
  end

end