# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
if Rails.env.test?
  Rails.application.config.assets.precompile += %w( jquery.simulate.js jquery.simulate.ext.js jquery.simulate.drag-n-drop.js)
end
Rails.application.config.assets.precompile += %w( tablesort.css dashboard.css bootstrap-slider.css )
Rails.application.config.assets.precompile += %w( broadcast_application.js moment.js modernizr.js bootstrap-slider.js )
