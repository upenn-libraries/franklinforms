require 'exception_notification/rails'

ExceptionNotification.configure do |config|
  # Ignore additional exception types.
  # ActiveRecord::RecordNotFound, Mongoid::Errors::DocumentNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
  # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

  # Adds a condition to decide when an exception must be ignored or not.
  # The ignore_if method can be invoked multiple times to add extra conditions.
  config.ignore_if do |_exception, _options|
    !Rails.env.production?
  end

  # Ignore exceptions generated by crawlers
  config.ignore_crawlers %w[Googlebot bingbot]

  # Use ExceptionNotification to send exception info to slack
  config.add_notifier :slack,
                      webhook_url: ENV['EXCEPTION_NOTIFIER_SLACK_WEBHOOK'],
                      channel: '#app-exceptions',
                      username: "Franklinforms (#{Rails.env})",
                      additional_parameters: {
                        icon_emoji: ':boom:',
                        mrkdwn: true
                      }
end
