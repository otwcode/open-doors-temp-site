class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :load_config
  def load_config
    @active_host ||= Rails.application.secrets[:ao3api][:active]
    @archive_config ||= ArchiveConfig.archive_config
    @api_config ||= Rails.application.secrets[:ao3api][@active_host.to_sym]
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def authorize
    redirect_to :login unless current_user
  end
end
