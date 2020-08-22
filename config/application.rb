require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# APP_CONFIG = YAML.load_file('config/config.yml')

module OpendoorsTempSite
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # config.assets.prefix = "/assets"
    config.autoload_paths += %W(#{config.root}/lib)
  end
end
