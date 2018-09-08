require "rails_helper"

describe AuthorsController, type: :controller do
  render_views

  before do
    create(:archive_config)

    # warning, these values are read from config/config.yml - this will not work on a deployed site
    @config = ArchiveConfig.archive_config
  end

  context "displays the header information" do
    let(:response) { get :index }

    it "displays the site name" do
      expect(response.body).to include(APP_CONFIG[:name])
    end

    # Broken by the new React front-end
    # TODO implement https://www.calebwoods.com/2015/11/01/testing-react-components-rails/
    # it "displays the send emails status" do
    #   expect(response.body).to include("Sending emails is")
    # end
    # 
    # it "displays the post as preview status" do
    #   expect(response.body).to include("posting as drafts is")
    # end
    # 
    # it "displays the collection" do
    #   expect(response.body).to include("Importing to ")
    # end
    # 
    # it "displays the archivist" do
    #   expect(response.body).to include(" as ")
    # end
  end
  # 
  context "displays the navigation bar" do
  #   let(:response) { get :index }
  # 
  #   it "displays the site logo" do
  #     expect(response.body).to include("<img src=\"/opendoorstempsite/assets/Opendoors")
  #   end
  # 
  #   it "includes the authors link" do
  #     expect(response.body).to include("Works by Author (use for importing)")
  #   end
  end
end
