require 'yaml'

# Get specific configuration for this app and its location
APP_CONFIG = YAML.load_file('config/config.yml')
app_dir = File.expand_path("../..", __FILE__)
shared_dir = "/home/opendoors_web/www/#{APP_CONFIG[:sitekey]}"

# Change to match your CPU core count
workers 1

# Min and Max threads per worker
threads 1, 6

# Default to production
rails_env = ENV['RAILS_ENV'] || "production"
environment rails_env

if rails_env == "production"

  # Set up socket location
  bind "unix://#{shared_dir}/runtime/sockets/puma.sock"

  # Logging
  stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

  # Set master PID and state locations
  pidfile "#{shared_dir}/runtime/pids/puma.pid"
  state_path "#{shared_dir}/runtime/pids/puma.state"
  activate_control_app

  on_worker_boot do
    require "active_record"
    ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
    ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
  end

else

  # Specifies the `port` that Puma will listen on to receive requests, default is 3010
  # (RubyMine's run configuration will override this)
  port        APP_CONFIG[:port] { 3010 }

  # Allow puma to be restarted by `rails restart` command.
  plugin :tmp_restart
end
