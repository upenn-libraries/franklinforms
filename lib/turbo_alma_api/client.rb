# frozen_string_literal: true

module TurboAlmaApi
  # support "Request form Penn Libraries" functionality
  class Client
    BASE_URL = ENV['ALMA_API_BASE_URL']
    DEFAULT_REQUEST_HEADERS =
      { "Authorization": "apikey #{ENV['ALMA_API_KEY']}",
        "Accept": 'application/json',
        "Content-Type": 'application/json' }.freeze

    class ItemNotFound < StandardError; end
    class RequestFailed < StandardError; end
    class Timeout < StandardError; end

    # Get all Items from the Alma API for a record without waiting too much
    # @return [TurboAlmaApi::Bib::ItemSet]
    # @param [String] mms_id
    # @param [String, nil] username
    def self.all_items_for(mms_id, username = nil)
      Bib::PennItemSet.new mms_id, username
    end

    # Get a single Item
    # @return [TurboAlmaApi::Bib::PennItem]
    # @param [Hash] identifiers
    def self.item_for(identifiers)
      unless all_identifiers_set?(identifiers)
        raise ArgumentError, 'Insufficient identifiers set'
      end

      response = api_get_request item_url(identifiers)
      parsed_response = Oj.load response.body
      raise ItemNotFound, "Item can't be found for: #{identifiers[:item_pid]}" if parsed_response['errorsExist']

      TurboAlmaApi::Bib::PennItem.new parsed_response
    end

    # see: https://developers.exlibrisgroup.com/alma/apis/docs/bibs/UE9TVCAvYWxtYXdzL3YxL2JpYnMve21tc19pZH0vcmVxdWVzdHM=/
    def self.submit_title_request(request); end

    # @param [LocalRequest] request
    def self.submit_request(request)
      query = { user_id: request.user.id, user_id_type: 'all_unique' }
      body = { request_type: 'HOLD', pickup_location_type: 'LIBRARY',
               pickup_location_library: request.pickup_location,
               comment: request.comments }
      response = Typhoeus.post request_url(request.mms_id, request.holding_id, request.item_pid),
                               headers: DEFAULT_REQUEST_HEADERS,
                               params: query,
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

    def self.api_get_request(url, headers = {})
      headers.merge! DEFAULT_REQUEST_HEADERS
      Typhoeus.get url, headers: headers
    end

    # Check if identifiers are sufficient to attempt an item lookup
    # @param [Hash] identifiers
    # @return [TrueClass, FalseClass]
    def self.all_identifiers_set?(identifiers)
      identifiers[:mms_id].present? &&
        identifiers[:holding_id].present? &&
        identifiers[:item_pid].present?
    end

    def self.request_url(mms_id, holding_id, item_id)
      "#{BASE_URL}/v1/bibs/#{mms_id}/holdings/#{holding_id}/items/#{item_id}/requests"
    end

    # @param [Hash] identifiers
    def self.item_url(identifiers)
      "#{BASE_URL}/v1/bibs/#{identifiers[:mms_id]}/holdings/#{identifiers[:holding_id]}/items/#{identifiers[:item_pid]}"
    end
  end
end