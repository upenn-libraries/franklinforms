# frozen_string_literal: true

class ParallelAlmaApi
  APIKEY = ENV['ALMA_API_KEY']
  BASE_URL = ENV['ALMA_API_BASE_URL']

  attr_reader :mms_id, :total_items, :bib_object

  def initialize(mms_id)
    @mms_id = mms_id
    response = api_get_request "#{BASE_URL}/v1/bibs/#{mms_id}"
    raise StandardError unless response.success?

    @bib_object = Alma::Bib.new Oj.load response.body
  end

  def items
    @items ||= retrieve_items
  end

  private

  # Run first item get query, across ALL holdings
  # If the total count is larger than the returned number of items,
  # queue additional requests to pull entire set of items, running requests
  # in parallel.
  # @return [Array<Alma::BibItem>]
  def retrieve_items
    first_response = api_get_request items_url(limit: 100)
    raise StandardError unless first_response.success?

    first_parsed_response = Oj.load first_response.body
    @total_items = first_parsed_response['total_record_count']
    items_data = if first_parsed_response['item'].length < @total_items
                   complete_item_responses(first_parsed_response)
                 else
                   first_parsed_response['item']
                 end
    items_data.map do |item_data|
      Alma::BibItem.new item_data
    end
  end

  # @param [Hash] first_response
  # @return [Array]
  def complete_item_responses(first_response)
    hydra = Typhoeus::Hydra.hydra
    additional_calls_needed = ((@total_items - first_response['item'].length) / 100) + 1
    additional_requests = (1..additional_calls_needed).map do |call_num|
      url = items_url(limit: 100, offset: (100 * call_num) + 1)
      request = Typhoeus::Request.new url, headers: request_headers
      hydra.queue request
      request
    end
    hydra.run
    additional_requests.map do |request|
      return nil unless request.response.success?

      parsed_response = Oj.load request.response.body
      parsed_response['item']
    end.prepend(first_response['item']).compact.flatten
  end

  def items_url(options = {})
    minimal_url = "#{BASE_URL}/v1/bibs/#{@mms_id}/holdings/ALL/items"
    minimal_url += '?' if options.any?
    minimal_url += "&user_id=#{options[:username]}" if options[:username].present?
    minimal_url += "&offset=#{options[:offset]}" if options[:offset].present?
    minimal_url += "&limit=#{options[:limit]}" if options[:limit].present?
    minimal_url
  end

  def api_get_request(url, headers = request_headers)
    Typhoeus.get url, headers: headers
  end

  def request_headers
    { "Authorization": "apikey #{APIKEY}",
      "Accept": 'application/json',
      "Content-Type": 'application/json' }
  end
end
