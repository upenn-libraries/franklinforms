Alma.configure do |config|
  config.apikey = Rails.env.test? ? 'test_api_key' : ENV['ALMA_API_KEY']
  config.timeout = 10
end
