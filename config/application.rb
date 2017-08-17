require_relative 'boot'

#require 'rails/all'
#require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_model/railtie'
#require 'active_job/railtie'
#require 'action_cable/engine'
require 'rails/test_unit/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FranklinForms
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.action_dispatch.ip_spoofing_check = false
    config.assets.prefix = '/redir/assets'

    unless Rails.env.development?
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.smtp_settings = {
        address: 'mailrelay.library.upenn.int',
      }
      config.action_mailer.default_options = { from: 'no-reply@upenn.edu' }
    end
  end
end
