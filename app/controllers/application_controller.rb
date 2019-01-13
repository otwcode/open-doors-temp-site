class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :load_config
  def load_config
    @archive_config ||= ArchiveConfig.archive_config
    @active_host = @archive_config&.host || "local"
    @api_config = Rails.application.secrets[:ao3api][@active_host.to_sym]
  end

  helper_method :current_user
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authorize
    redirect_to :login unless current_user || request.xhr?
  end

  def log_error(e, location, response)
    Rails.logger.error("\n-----------------\nERROR in #{location}")
    Rails.logger.error("response: #{response}")
    Rails.logger.error(e.message)
    Rails.logger.error(e.backtrace[0...15].join("\n"))
    Rails.logger.error("------------------")
  end

  # Return a standard HTTP + Json envelope for errors that drop through other handling
  def render_standard_error_response(exception)
    log_error(exception, "render_standard_error_response", {})
    type = exception.class
    message = "An error occurred: #{exception.message}"
    render status: :internal_server_error,
           json: {status: :internal_server_error, messages: message, type: type}
  end
end
