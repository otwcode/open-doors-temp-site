Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = false
  # Settings specified here will take precedence over those in config/application.rb.
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true
  config.eager_load_paths += ['lib/']

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
        'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :debug

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :request_id ]

  # Raise an error on page load if there are pending migrations.
  # config.active_record.migration_error = :page_load

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker
end


# Rails.application.configure do

#   # Disable serving static files from the `/public` folder by default since
#   # Apache or NGINX already handles this.
#   config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
#
#   # Compress JavaScripts and CSS.
#   config.assets.js_compressor = :uglifier
#   # config.assets.css_compressor = :sass
#
#   # Do not fallback to assets pipeline if a precompiled asset is missed.
#   config.assets.compile = false
#
#   # Use a different cache store in production.
#   # config.cache_store = :mem_cache_store
#
#   # Use a real queuing backend for Active Job (and separate queues per environment)
#   # config.active_job.queue_adapter     = :resque
#   # config.active_job.queue_name_prefix = "opendoors-temp-site_#{Rails.env}"
#   config.action_mailer.perform_caching = false
#
#   # Ignore bad email addresses and do not raise email delivery errors.
#   # Set this to true and configure the email server for immediate delivery to raise delivery errors.
#   # config.action_mailer.raise_delivery_errors = false
#
#   # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
#   # the I18n.default_locale when a translation cannot be found).
#   config.i18n.fallbacks = true
#
#   # Send deprecation notices to registered listeners.
#   config.active_support.deprecation = :notify
#
#
#   if ENV["RAILS_LOG_TO_STDOUT"].present?
#     logger           = ActiveSupport::Logger.new(STDOUT)
#     logger.formatter = config.log_formatter
#     config.logger = ActiveSupport::TaggedLogging.new(logger)
#   end
#
#   # Do not dump schema after migrations.
#   config.active_record.dump_schema_after_migration = false
#
#   #
#   config.relativeurlroot = "/#{APP_CONFIG[:sitekey]}"
# end
