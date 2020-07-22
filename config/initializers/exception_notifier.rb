if Rails.env.production?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
                                          slack: {
                                            webhook_url: ENV['EXCEPTION_NOTIFIER_SLACK_WEBHOOK'],
                                            channel: '#app-exceptions',
                                            username: "Franklinforms (#{Rails.env})",
                                            additional_parameters: {
                                              icon_emoji: ':boom:',
                                              mrkdwn: true
                                            }
                                          }
end