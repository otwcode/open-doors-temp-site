require "rails_helper"

describe ArchiveConfigsController, type: :controller do
  before do
    site_config = ArchiveConfig.new(id: 1, key: "key")
    allow(ArchiveConfig).to receive(:archive_config).and_return(site_config)
  end

  it "redirects to login" do
    get :show, params: {id: 1}
    assert_redirected_to :login
  end

  context "with current user" do
    before do
      user = User.new
      allow(controller).to receive(:current_user).and_return(user)
    end

    it "should show archive_config" do
      get :show, params: { id: 1 }
      assert_response :success
    end

    it "should get edit" do
      get :edit, params: { id: 1 }
      assert_response :success
    end

    it "should update archive_config" do
      put :update, params: { archive_config: { id: 1, name: "New name" } }
      expect(assigns(:archive_config).name).to eq "New name"
    end
  end
end
