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

  # Submit a transaction request and return transaction number if successful
  # @param [Hash] transaction_data
  # @return [String, nil]
  def transaction(transaction_data)
    options = @default_options
    options[:body] = transaction_data
    response = self.class.post('/transaction', options)
    parsed_response = JSON.parse response.body
    if parsed_response.key? 'TransactionNumber'
      parsed_response['TransactionNumber']
    else
      Rails.logger.error "Illiad API request failure: #{response.message}"
      nil
    end
  end

  # @param [String] username
  # @return [Hash, nil] parsed response
  def user_info(username)
    response = self.class.get("/users/#{username}", @default_options)
    if response.code == 200
      JSON.parse response.body
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