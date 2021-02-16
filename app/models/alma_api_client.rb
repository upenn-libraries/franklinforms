class AlmaApiClient
  include HTTParty

  class ItemNotFound < StandardError; end
  class RequestFailed < StandardError; end
  class Timeout < StandardError; end

  base_uri Alma.configuration.region

  def apikey
    Alma.configuration.apikey
  end

  # @param [Hash] identifiers
  # @return [Alma::BibItem]
  def find_item_for(identifiers)
    unless all_identifiers_set?(identifiers)
      raise ArgumentError, 'Insufficient identifiers set'
    end

    response = self.class.get item_url(identifiers),
                              query: default_query
    raise ItemNotFound, "Item can't be found for: #{identifiers[:item_pid]}" if response['errorsExist']

    Alma::BibItem.new response
  end

  # see: https://developers.exlibrisgroup.com/alma/apis/docs/bibs/UE9TVCAvYWxtYXdzL3YxL2JpYnMve21tc19pZH0vcmVxdWVzdHM=/
  def create_title_request(request); end

  # @param [LocalRequest] request
  def create_item_request(request)
    query = default_query.merge({ user_id: request.user.id, user_id_type: 'all_unique' })
    headers = { 'Content-Type' => 'application/json' }
    body = { request_type: 'HOLD',
             pickup_location_type: 'LIBRARY',
             pickup_location_library: request.pickup_location,
             comment: request.comments }.to_json
    response = self.class.post request_url(request.mms_id, request.holding_id, request.item_pid),
                               headers: headers,
                               query: query,
                               body: body
    if response['errorsExist']
      raise RequestFailed, 'Alma Request submission failed' # TODO: error message details
      # boo, get error code
      # 401890 User with identifier X of type Y was not found.
      # 401129 No items can fulfill the submitted request.
      # 401136 Failed to save the request: Patron has active request for selected item.
      # 60308 Delivery to personal address is not supported.
      # 60309 User does not have address for personal delivery.
      # 60310 Delivery is not supported for this type of personal address.
      # 401684 Search for request physical item failed.
      # 60328 Item for request was not found.
      # 60331 Failed to create request.
      # 401652 General Error - An error has occurred while processing the request.
    else
      # TODO: get confirmation code/request id
      true
      # hooray!
    end
  end

  private

  def default_query
    { apikey: apikey, format: 'json' }
  end

  # Check if identifiers are sufficient to attempt an item lookup
  # @param [Hash] identifiers
  # @return [TrueClass, FalseClass]
  def all_identifiers_set?(identifiers)
    identifiers[:mms_id].present? &&
      identifiers[:holding_id].present? &&
      identifiers[:item_pid].present?
  end

  def request_url(mms_id, holding_id, item_id)
    "/almaws/v1/bibs/#{mms_id}/holdings/#{holding_id}/items/#{item_id}/requests"
  end

  # @param [Hash] identifiers
  def item_url(identifiers)
    "/almaws/v1/bibs/#{identifiers[:mms_id]}/holdings/#{identifiers[:holding_id]}/items/#{identifiers[:item_pid]}"
  end
end
