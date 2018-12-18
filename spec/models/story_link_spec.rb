require 'rails_helper'

describe StoryLink, type: :model do
  let!(:author1) { create(:author_with_stories, audit_comment: "Test") }
  let(:story_link) { create(:story_link, author_id: author1.id, notes: "Original Notes", audit_comment: "Test") }

  it 'should convert a story link to a bookmark with all fields correct' do
    config = create(:archive_config, bookmarks_note: "Bookmark note")
    bookmark = story_link.to_bookmark(config)
    expect(bookmark.notes).to eq "Bookmark note\nOriginal Notes"
  end
end