class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :load_config
  def load_config
    @active_host = Rails.application.secrets[:ao3api][:active]
    @site_config = ArchiveConfig.site_config
  end

end
