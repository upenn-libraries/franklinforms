class IlliadApiClient
  include HTTParty

  class UserNotFound < StandardError; end
  class RequestFailed < StandardError; end
  class InvalidRequest < StandardError; end

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
    options[:body] = transaction_data.to_json
    response = self.class.post('/transaction', options)
    parsed_response = JSON.parse response.body
    if parsed_response.key? 'TransactionNumber'
      parsed_response['TransactionNumber']
    else
      raise RequestFailed, response.message
    end
  end

  # Get user info from Illiad
  # @param [String] username
  # @return [Hash, nil] parsed response
  def get_user(username)
    respond_to self.class.get("/users/#{username}", @default_options), UserNotFound
  end

  # Create an Illiad user with a username, at least
  # @param [Hash] user_info
  # @return [Hash, nil]
  def create_user(user_info)
    options = @default_options
    raise InvalidRequest unless valid? user_info

    options[:body] = user_info.to_json
    respond_to self.class.post('/users', options)
  end

  private

  def respond_to(response, exception_class = RequestFailed)
    if response.code == 200
      JSON.parse(response.body).transform_keys { |k| k.downcase.to_sym }
    else
      raise exception_class, response.body
    end
  end

  # Checks if user_info includes minimum required Illiad API fields
  # @param [Hash] user_info
  # @return [TrueClass, FalseClass]
  def valid?(user_info)
    user_info&.dig('Username').present?
  end

  def headers
    { 'ApiKey' => ENV['ILLIAD_API_KEY'],
      'Accept' => 'application/json; version=1' }
  end
end