# frozen_string_literal: true

require 'rails_helper'

describe Item, type: :model do
  it 'returns summary too long errors' do
    stub_const("SUMMARY_LENGTH", 4)
    author = create(:author)
    story = create(:story, author_id: author.id, title: "title", summary: "Longer than 4 characters", audit_comment: "Test")
    story_link = create(:story_link, author_id: author.id, title: "title", summary: "Longer than 4 characters", audit_comment: "Test")
    errors = Item.all_errors(author.id.to_s)
    expect(errors.key?(author.id)).to eq true
    expect(errors[author.id].include?("Summary for story 'title' is too long (24)")).to eq true
    expect(errors[author.id].include?("Summary for bookmark 'title' is too long (24)")).to eq true
  end

  it 'returns notes too long errors' do
    stub_const("NOTES_LENGTH", 4)
    author = create(:author)
    story = create(:story, author_id: author.id, title: "title", notes: "Longer than 4 characters", audit_comment: "Test")
    story_link = create(:story_link, author_id: author.id, title: "title", notes: "Longer than 4 characters", audit_comment: "Test")
    errors = Item.all_errors(author.id.to_s)
    expect(errors.key?(author.id)).to eq true
    expect(errors[author.id].include?("Notes for story 'title' is too long (24)")).to eq true
    expect(errors[author.id].include?("Notes for bookmark 'title' is too long (24)")).to eq true
  end

  it 'returns missing fandoms errors' do
    author = create(:author)
    story = create(:story, author_id: author.id, title: "title", audit_comment: "Test")
    story_link = create(:story_link, author_id: author.id, title: "title", audit_comment: "Test")
    errors = Item.all_errors(author.id.to_s)
    expect(errors.key?(author.id)).to eq true
    expect(errors[author.id].include?("Fandom for story 'title' is missing")).to eq true
    expect(errors[author.id].include?("Fandom for bookmark 'title' is missing")).to eq true
  end

  it 'returns chapter notes too long errors' do
    stub_const("NOTES_LENGTH", 4)
    author = create(:author)
    story = create(:story, author_id: author.id, title: "title", audit_comment: "Test")
    chapter = create(:chapter, story_id: story.id, position: 1, notes: "Longer than 4 characters", audit_comment: "Test")
    errors = Item.all_errors(author.id.to_s)
    expect(errors.key?(author.id)).to eq true
    expect(errors[author.id].include?("Notes for chapter 1 in story 'title' is too long (24)")).to eq true
  end

  it 'returns chapter text too long errors' do
    stub_const("CHAPTER_LENGTH", 4)
    author = create(:author)
    story = create(:story, author_id: author.id, title: "title", audit_comment: "Test")
    chapter = create(:chapter, story_id: story.id, position: 1, text: "Longer than 4 characters", audit_comment: "Test")
    errors = Item.all_errors(author.id.to_s)
    expect(errors.key?(author.id)).to eq true
    expect(errors[author.id].include?("Text for chapter 1 in story 'title' is too long (24)")).to eq true
  end
end
