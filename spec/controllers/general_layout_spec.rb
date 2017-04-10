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
      Rails.logger.info(config.inspect)
      expect(response.body).to include(APP_CONFIG[:name])
    end

    it "displays the send emails status"
    it "displays the post as preview status"
    it "displays the collection"
    it "displays the archivist"
    it "displays the archive server as a link"
  end
end
