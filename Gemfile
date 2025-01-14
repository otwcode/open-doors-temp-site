source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby "2.7.3"

# Use SCSS for stylesheets (sassc-rails needs be before rails https://github.com/sass/sassc-rails/issues/114)
gem 'sassc-rails', '~> 2.1.2'
gem 'net-imap', '0.3.1'
# gem 'date', '3.2.2'
gem 'timeout', '0.3.0'
gem 'rails', '5.2.6.2'

gem 'mysql2', '0.5.3'

gem 'faraday', '1.10.2'
gem 'faraday_middleware', '1.2.0'

gem 'audited', '~> 5.0'

# Use React for the front end
gem 'react-rails', '2.6.2'
gem 'webpacker', '5.4.3'


# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.6'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.17'

# Adding because version 1.17 throws an unsupported rubygems error
gem "ffi", '~> 1.15.5'

group :development do
  # Use Puma as the app server
  gem 'puma', '~> 5.6'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  # gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'derailed_benchmarks'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem "capybara"
  gem "coveralls"
  gem "factory_bot_rails"
  gem "rails-controller-testing"
  gem "rspec-rails"
  gem "selenium-webdriver"
  gem "simplecov"
  gem "webmock"
end

group :production do
  gem "unicorn"
end
