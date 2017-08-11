require 'rails_helper'

RSpec.describe StatsController, type: :controller do
  before do
    site_config = ArchiveConfig.new(id: 1, key: "key")
    allow(ArchiveConfig).to receive(:archive_config).and_return(site_config)
  end


end
