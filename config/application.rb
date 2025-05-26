require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CartaQr
  class Application < Rails::Application
    # Module documentation comment for CartaQr::Application
    # Main application configuration class that sets up defaults and locale settings
    config.load_defaults 8.0

    config.active_support.to_time_preserves_timezone = :zone

    config.rails_i18n.enabled_modules = [:locale]

    # Catalan, Galician, Basque, English, French, Italian, German, Portuguese, Russian
    config.i18n.available_locales = [:es, :cat, :gl, :eus, :en, :fr, :it, :de, :pt, :ru]
    config.i18n.default_locale = :es
    config.i18n.fallbacks.default = [:es]

    # ../data/locales
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '*.{rb,yml}')]

    # add services
    # config.autoload_paths += %W(#{config.root}/app/services)
    config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
