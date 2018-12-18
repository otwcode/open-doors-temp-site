# frozen_string_literal: true

require 'rails_helper'

describe Story, type: :model do

  it 'returns a summary too long error in json object' do
    stub_const("SUMMARY_LENGTH", 4)
    story = Story.new(
      title: "title",
      summary: "Longer than 4 characters",
      chapters: [Chapter.new(text: "some text")])
    expect(story.as_json[:errors]).to eq ["Summary for story 'title' is too long (24)"]
  end

  it 'returns a chapter text too long error in json object' do
    stub_const("CHAPTER_LENGTH", 4)
    story = Story.new(
      title: "title",
      chapters: [Chapter.new(text: "some text")])
    expect(story.as_json[:errors]).to eq ["Chapter  in story 'title' is too long (9)"]
  end
end