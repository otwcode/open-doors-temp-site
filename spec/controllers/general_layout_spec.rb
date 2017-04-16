require 'rails_helper'

describe AuthorsController, type: :controller do
  render_views

  before do
    create(:archive_config)

    # warning, these values are read from config/config.yml - this will not work on a deployed site
    @config = ArchiveConfig.site_config
  end

  context 'displays the header information' do
    let(:response) { get :index }

    it "displays the site name" do
      expect(response.body).to include(APP_CONFIG[:name])
    end

    it "displays the send emails status" do
      expect(response.body).to include("Send emails:")
    end

    it "displays the post as preview status" do
      expect(response.body).to include("Post works as drafts:")
    end

    it "displays the collection" do
      expect(response.body).to include("Collection:")
    end

    it "displays the archivist" do
      expect(response.body).to include("Archivist:")
    end

    it "displays the archive server" do
      expect(response.body).to include("Archive server:")
    end
  end

  context "displays the navigation bar" do
    let(:response) { get :index }

    it "displays the site logo" do
      expect(response.body).to include("<img src=\"/opendoorstempsite/assets/Opendoors")
    end

    it "includes the authors link" do
      expect(response.body).to include("Works by Author (use for importing)")
    end
  end
end
