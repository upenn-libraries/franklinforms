class IlliadApi
  include HTTParty
  base_uri ENV['ILLIAD_API_BASE_URI']

  def initialize
    @default_options = { headers: headers }
  end

  def version
    self.class.get '/SystemInfo/APIVersion'
  end

  def secure_version
    self.class.get '/SystemInfo/SecurePlatformVersion', @default_options
  end

  def transaction(transaction_data)
    options = @default_options
    options[:body] = transaction_data
    response = self.class.post('/transaction', options)
    if response.parsed_response.key? 'TransactionNumber'
      response.parsed_response['TransactionNumber']
    else
      Rails.logger.error "Illiad API request failure: #{response.message}"
      nil
    end
  end

  def user_info(username)
    response = self.class.get("/users/#{username}", @default_options)
    if response.code == 200
      response.parsed_response.transform_keys { |k| k.downcase.to_sym }
    else
      nil
    end
  end

  def add_user(user_info)
    options = @default_options
    options[:body] = user_info
    self.class.post('/Users', options)
  end

  private

  def headers
    { 'ApiKey' => ENV['ILLIAD_API_KEY'],
      'Accept' => 'application/json; version=1' }
  end
end