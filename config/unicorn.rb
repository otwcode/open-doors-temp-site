require 'yaml'

# Get specific configuration for this app and its location
app_dir = File.expand_path("../..", __FILE__)
APP_CONFIG = YAML.load_file("#{app_dir}/config/config.yml")
shared_dir = "/var/www/sites/#{ENV['RAILS_RELATIVE_URL_ROOT']}"

working_directory app_dir

# Set unicorn options
worker_processes 2
preload_app true
timeout 300

# Path for the Unicorn socket
listen "#{shared_dir}/runtime/sockets/unicorn.sock", backlog: 64

# Set path for logging
stderr_path "#{shared_dir}/log/unicorn.stderr.log"
stdout_path "#{shared_dir}/log/unicorn.stdout.log"

# Set proccess id path
pid "#{shared_dir}/runtime/pids/unicorn.pid"

require "active_record"
before_fork do |_server, _worker|
  # other settings
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  end
end

after_fork do |_server, _worker|
  # other settings
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

