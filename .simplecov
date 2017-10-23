require 'simplecov'
require 'coveralls'

SimpleCov.start do
  add_filter ".simplecov"
  add_filter "config.ru"
  add_filter "Rakefile"
  add_filter "Vagrantfile"
  add_filter "/db/"
  add_filter "/spec/"
  add_filter "/test/"
end
