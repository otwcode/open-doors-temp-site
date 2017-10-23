require "rails_helper"

describe ArchiveConfigsController, type: :controller do
  before do
    site_config = create(:archive_config)
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

    it "shows the current archive_config" do
      get :show, params: { id: 1 }
      assert_response :success
    end

    it "displays the edit page" do
      get :edit, params: { id: 1 }
      assert_response :success
    end

    it "updates the archive_config when it is valid" do
      put :update, params: { archive_config: { id: 1, name: "New name", host: "local" } }
      expect(assigns(:archive_config).name).to eq "New name"
    end
    
    it "redirects to the edit page if the config is invalid" do
      put :update, params: { archive_config: { id: nil, name: nil, host: nil } }
      expect(response).to render_template(:edit)
    end
  end
end
