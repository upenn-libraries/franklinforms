# frozen_string_literal: true


module ParallelAlmaApi

  APIKEY = ENV['ALMA_API_KEY']
  BASE_URL = ENV['ALMA_API_BASE_URL']

  attr_reader :mms_id

  class Bib < OpenStruct
    def initialize(mms_id)
      @mms_id = mms_id
      response = Typhoeus.get "#{BASE_URL}/v1/bibs/#{mms_id}",
                              headers: { "Authorization": "apikey #{APIKEY}",
                                         "Accept": 'application/json',
                                         "Content-Type": 'application/json' }
      raise StandardError unless response.success?

      super Oj.load response.body
    end

    def all_holdings # .holdings conflicts with OpenStruct accessor from response key
      @holdings ||= retrieve_holdings_data
    end
    
    def all_items
      @items ||= retrieve_items_data
    end
    
    def retrieve_holdings_data
      url = holdings['link']
      response = Typhoeus.get url,
                              headers: { "Authorization": "apikey #{APIKEY}",
                                         "Accept": 'application/json',
                                         "Content-Type": 'application/json' }
      raise StandardError, response.body unless response.success?

      parsed_response = Oj.load response.body
      parsed_response[@mms_id].map do |holding_data|
        Holding.new holding_data, self
      end
    end

    def retrieve_items_data
      items = []
      first_response = Typhoeus.get items_url(limit: 100),
                                    headers: { "Authorization": "apikey #{APIKEY}",
                                               "Accept": 'application/json',
                                               "Content-Type": 'application/json' }
      raise StandardError unless first_response.success?

      first_parsed_response = Oj.load first_response.body
      total_items = first_parsed_response['total_record_count']
      puts "Total Items: #{total_items}"
      items_data = first_parsed_response['item']
      hydra = Typhoeus::Hydra.hydra
      
      if items_data.length < total_items
        additional_calls_needed = ((total_items - items_data.length) / 100) + 1
        puts "Additional Calls Needed: #{additional_calls_needed}"
        additional_requests = (1..additional_calls_needed).map do |call_num|
          url = items_url(limit: 100, offset: (100 * call_num) + 1)
          puts "Queueing #{url}"
          request = Typhoeus::Request.new url,
                                          headers: { "Authorization": "apikey #{APIKEY}",
                                                     "Accept": 'application/json',
                                                     "Content-Type": 'application/json' }
          hydra.queue request
          request
        end
      end

      hydra.run
      puts 'Hydra run complete'

      responses = additional_requests.map do |request|
        return nil unless request.response.success?

        parsed_response = Oj.load request.response.body
        parsed_response['item']
      end.prepend(first_parsed_response['item']).flatten

      puts responses.length
    end

    def items_url(options = {})
      minimal_url = "#{BASE_URL}/v1/bibs/#{@mms_id}/holdings/ALL/items"
      minimal_url += '?' if options.any?
      minimal_url += "&user_id=#{options[:username]}" if options[:username].present?
      minimal_url += "&offset=#{options[:offset]}" if options[:offset].present?
      minimal_url += "&limit=#{options[:limit]}" if options[:limit].present?
      minimal_url
    end
  end

  class Holding < OpenStruct
    def initialize(holding_data, bib)
      @bib = bib
      super holding_data
    end
  end

  class Item < OpenStruct
    def initialize(item_data, bib)
      @bib = bib
      super item_data
    end
  end

end
