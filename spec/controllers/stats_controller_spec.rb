require 'rails_helper'

RSpec.describe StatsController, type: :controller do

  it "redirects to login if not logged in" do
    get :stats, params: {id: 1}
    assert_redirected_to :login
  end

  context "with current user" do
    before do
      user = User.new
      allow(controller).to receive(:current_user).and_return(user)
    end

    it "shows the stats page" do
      get :stats
      assert_response :success
    end
  end

  context "stats methods" do
    it "returns the author stats" do
      author = create(:author, imported: true)
      result = controller.item_stats(Author)
      expect(result).to be_a(OpenStruct)
      expect(result.all).to eq 1
      expect(result.imported).to eq 1
      expect(result.not_imported).to eq 0
      expect(result.dni).to eq 0
    end

    it "returns the story stats" do
      author = create(:author)
      story = create(:story, author_id: author.id, audit_comment: "Test")
      result = controller.item_stats(Story)
      expect(result).to be_a(OpenStruct)
      expect(result.all).to eq 1
      expect(result.imported).to eq 0
      expect(result.not_imported).to eq 1
      expect(result.dni).to eq 0
    end

    it "returns the story link stats" do
      author = create(:author)
      story_link = create(:story_link, author_id: author.id, audit_comment: "Test")
      result = controller.item_stats(StoryLink)
      expect(result).to be_a(OpenStruct)
      expect(result.all).to eq 1
      expect(result.imported).to eq 0
      expect(result.not_imported).to eq 1
      expect(result.dni).to eq 0
    end

    it "returns all the stats" do
      author = create(:author)
      story = create(:story, author_id: author.id, audit_comment: "Test")
      story_link = create(:story_link, author_id: author.id, audit_comment: "Test")
      result = controller.gather_stats
      expect(result).to be_a(OpenStruct)
      expect(result.authors.all).to eq 1
      expect(result.letters.all).to eq 1
      expect(result.stories.all).to eq 1
      expect(result.story_links.all).to eq 1
    end
  end

end
