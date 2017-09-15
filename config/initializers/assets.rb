# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
stylesheets = <<-CSS_FILES
  bootstrap.min.css now-ui-kit.css bootstrap-datetimepicker.css main.css
CSS_FILES
javascripts = <<-JS_FILES
  core/jquery.3.2.1.min.js core/popper.min.js core/bootstrap.min.js plugins/bootstrap-switch.js
  plugins/nouislider.min.js plugins/bootstrap-datepicker.js now-ui-kit.js moment.js moment/vi.js
  bootstrap-datetimepicker.js
JS_FILES
Rails.application.config.assets.precompile += stylesheets.split(" ") + javascripts.split(" ")
