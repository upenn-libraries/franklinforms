class RequestSubmissionService
  # Receive a request (currently a LocalRequest, but later a more abstract Request?)
  # Return a hash if success { status: :success }
  # Return a hash if failed { status: :failed, message: '' }
  # @param [LocalRequest] request
  # @param [AlmaUser] alma_user
  def self.submit(request, alma_user)
    case request.target_system
    when :alma
      alma_request AlmaApiClient.request_data_from request
    when :illiad
      illiad_transaction IlliadApiClient.transaction_data_from(request), alma_user
    else
      raise ArgumentError, "Unsupported submission target system: #{request.target_system}"
    end
  end

  # @param [Hash] transaction_data
  # @param [AlmaUser] alma_user
  def self.illiad_transaction(transaction_data, alma_user)
    illiad_user = get_or_create_illiad_user(alma_user)
    data = {} # TODO: get data in proper format
    IlliadApiClient.new.transaction transaction_data
  end

  def self.alma_request(request_data)
    AlmaApiClient.new.create_item_request request_data
  end

  # maybe one day?
  # def self.aeon_transaction(request)
  #
  # end


end