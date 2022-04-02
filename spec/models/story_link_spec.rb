require 'rails_helper'

describe StoryLink, type: :model do
  let!(:author1) { create(:author_with_stories, audit_comment: "Test") }
  let(:story_link) { create(:story_link, author_id: author1.id, notes: "Original Notes", audit_comment: "Test") }

  it 'converts a story link to a bookmark with all fields correct' do
    config = create(:archive_config, bookmarks_note: "Bookmark note")
    bookmark = story_link.to_bookmark(config)
    expect(bookmark.notes).to eq "Bookmark note\n<br/><br/><p>--</p><br/>Original Notes"
    expect(bookmark.language_code).to eq "en"
  end

  it 'returns a summary too long error in json object' do
    stub_const("SUMMARY_LENGTH", 4)
    story = StoryLink.new(
      title: "title",
      fandoms: "Foo",
      summary: "Longer than 4 characters")
    expect(story.as_json[:errors]).to eq ["Summary for story link 'title' is too long (24)"]
  end

  it 'returns a fandom is missing error in json object' do
    story = StoryLink.new(
      title: "title",
      fandoms: nil)
    expect(story.as_json[:errors]).to eq ["Fandom for story link 'title' is missing"]
  end

end