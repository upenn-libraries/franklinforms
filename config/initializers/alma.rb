Alma.configure do |config|
  # You have to set the apikey
  config.apikey     = ENV['ALMA_API_KEY']
  # Alma gem defaults to querying Ex Libris's North American Api servers. You can override that here.
  # config.region   = "https://api-eu.hosted.exlibrisgroup.com
end
