# Be sure to restart your server when you modify this file.

Rails.application.configure do
  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.1'

  # Add additional assets to the asset load path
  # Rails.application.config.assets.paths << Emoji.images_path

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # Rails.application.config.assets.precompile += %w( search.js )

  config.assets.precompile += %w( jquery-3.1.1.min.js alphabetical_paginate.js )
end
