# frozen_string_literal: true

# Get all Items from the Alma API for a record without waiting too much
class ParallelAlmaApi
  APIKEY = ENV['ALMA_API_KEY']
  BASE_URL = ENV['ALMA_API_BASE_URL']

  # minimize API requests overall for now, but a lower number may give better
  # overall performance?
  ITEMS_PER_REQUEST = 100

  attr_reader :mms_id, :total_items, :bib_object

  # Initializes object and pulls availability and bib info for given mms_id
  # Optionally, user-specific data can be returned with Items by passing an Alma
  # username on initialization
  # @param [String] mms_id
  # @param [String, nil] alma_username
  def initialize(mms_id, alma_username = nil)
    @alma_username = alma_username
    @mms_id = mms_id
    availability_response = Alma::Bib.get_availability(Array.wrap(@mms_id))
    @total_items = availability_response.total_items
    @bib_object = Alma::Bib.new availability_response.bib_data
  end

  # Grabs all Items for @mms_id and returns them as Alma::BibItems
  # @return [Array<Alma::BibItem>]
  def items
    @items ||= retrieve_items
  end

  private

  # @return [Array<Alma::BibItem>]
  def retrieve_items
    requests_needed = (@total_items / ITEMS_PER_REQUEST) + 1
    hydra = Typhoeus::Hydra.hydra
    requests = (1..requests_needed).map do |request_number|
      request_url = items_url limit: ITEMS_PER_REQUEST,
                              offset: offset_for(request_number),
                              username: @alma_username
      request = Typhoeus::Request.new request_url, headers: request_headers
      hydra.queue request
      request
    end
    hydra.run # runs all requests in parallel
    requests.map do |request|
      return nil unless request.response.success?

      parsed_response = Oj.load request.response.body
      parsed_response['item']&.map { |item_data| Alma::BibItem.new item_data }
    end.compact.flatten
  end

  # @param [Fixnum] request_number
  # @return [Fixnum]
  def offset_for(request_number)
    return 0 if request_number == 1

    (ITEMS_PER_REQUEST * (request_number - 1)) + 1
  end

  # @param [Hash] options
  # @return [String (frozen)]
  def items_url(options = {})
    minimal_url = "#{BASE_URL}/v1/bibs/#{@mms_id}/holdings/ALL/items?order_by=description&direction=asc"
    minimal_url += "&user_id=#{options[:username]}" if options[:username].present?
    minimal_url += "&offset=#{options[:offset]}" if options[:offset].present?
    minimal_url += "&limit=#{options[:limit]}" if options[:limit].present?
    minimal_url
  end

  # @param [String] url
  # @param [Hash] headers
  def api_get_request(url, headers = request_headers)
    Typhoeus.get url, headers: headers
  end

  # @return [Hash{Symbol->String (frozen)}]
  def request_headers
    { "Authorization": "apikey #{APIKEY}",
      "Accept": 'application/json',
      "Content-Type": 'application/json' }
  end
end
