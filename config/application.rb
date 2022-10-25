require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FeedNews
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    # config.autoload_paths += Dir[Rails.root.join('app', 'services', '**/')]

    config.load_defaults 7.0
    config.active_storage.variant_processor = :mini_magick
    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.view_component.preview_paths << "#{Rails.root}/spec/components/previews"

    config.after_initialize do
      Rails::Html::WhiteListSanitizer.allowed_attributes.add 'style'
      Rails::Html::WhiteListSanitizer.allowed_attributes.add 'controls'
      Rails::Html::WhiteListSanitizer.allowed_attributes.add 'poster'

      Rails::Html::WhiteListSanitizer.allowed_tags.add 'video'
      Rails::Html::WhiteListSanitizer.allowed_tags.add 'audio'
      Rails::Html::WhiteListSanitizer.allowed_tags.add 'source'
      Rails::Html::WhiteListSanitizer.allowed_tags.add 'embed'
      Rails::Html::WhiteListSanitizer.allowed_tags.add 'iframe'
    end
  end
end
