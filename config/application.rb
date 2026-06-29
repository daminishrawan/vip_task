# config/application.rb
require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module BrewHub
  class Application < Rails::Application
    config.load_defaults 8.1

    # Tell Rails to process background tasks via Sidekiq
    config.active_job.queue_adapter = :sidekiq

    # Only if you need API-only behavior configuration
    config.api_only = true
  end
end
