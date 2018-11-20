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
      author = Author.new(name: "Name", email: "foo@ao3.org")
      authors = [author]
      result = controller.author_stats(authors)
      expect(result).to be_a(OpenStruct)
      expect(result.all).to eq 1
      expect(result.imported).to eq 1
      expect(result.not_imported).to eq 0
      expect(result.dni).to eq 0
    end

    it "returns the story stats" do
      author = Author.new(name: "Name", email: "foo@ao3.org")
      story = Story.new(title: "Name", author: author)
      stories = [story]
      result = controller.story_stats(stories)
      expect(result).to be_a(OpenStruct)
      expect(result.all).to eq 1
      expect(result.imported).to eq 0
      expect(result.not_imported).to eq 1
      expect(result.dni).to eq 0
    end

    it "returns the story link stats" do
      author = Author.new(name: "Name", email: "foo@ao3.org")
      story_link = StoryLink.new(title: "Name", author: author)
      story_links = [story_link]
      result = controller.story_stats(story_links)
      expect(result).to be_a(OpenStruct)
      expect(result.all).to eq 1
      expect(result.imported).to eq 0
      expect(result.not_imported).to eq 1
      expect(result.dni).to eq 0
    end

    it "returns all the stats" do
      author = Author.new(name: "Name", email: "foo@ao3.org")
      story = Story.new(title: "Name", author: author)
      story_link = StoryLink.new(title: "Name", author: author)
      result = controller.gather_stats([author], [story], [story_link])
      expect(result).to be_a(OpenStruct)
      expect(result.authors.all).to eq 1
      expect(result.letters.all).to eq 1
      expect(result.stories.all).to eq 1
      expect(result.story_links.all).to eq 1
    end
  end

end
