module MockAlmaApi
  include JsonFixtures

  def stub_user_get_success
    stub(
      :get,
      "#{Alma.configuration.region}/almaws/v1/users/testuser?expand=fees,requests,loans",
      'user_get_success.json'
    )
  end

  def stub_bib_get_success
    stub(
      :get,
      "#{Alma.configuration.region}/almaws/v1/bibs?expand=p_avail,e_avail,d_avail&mms_id=9922327423503681",
      'bib_get_success.json'
    )
  end

  def stub_items_get_success
    stub(
      :get,
      "#{Alma.configuration.region}/almaws/v1/bibs/9922327423503681/holdings/22410814720003681/items?expand=due_date,due_date_policy&limit=100&user_id=GUEST",
      'items_get_success.json'
    )
  end

  def stub_item_get_success
    stub(
      :get,
      "#{Alma.configuration.region}/almaws/v1/bibs/1234/holdings/2345/items/3456?apikey=test_api_key&format=json",
      'item_get_success.json'
    )
  end

  def stub_item_get_failure
    stub(
      :get,
      "#{Alma.configuration.region}/almaws/v1/bibs/1234/holdings/2345/items/9876?apikey=test_api_key&format=json",
      'item_get_failure.json'
    )
  end

  def stub_request_post_success
    stub(
      :post,
      "#{Alma.configuration.region}/almaws/v1/bibs/1234/holdings/2345/items/3456/requests?apikey=test_api_key&format=json&user_id=&user_id_type=all_unique",
      'request_post_success.json'
    )
  end

  def stub_request_post_failure
    stub(
      :post,
      "#{Alma.configuration.region}/almaws/v1/bibs/1234/holdings/2345/items/9876/requests?apikey=test_api_key&format=json&user_id=&user_id_type=all_unique",
      'request_post_failure.json'
    )
  end

  private

  # @param [Symbol] http_method
  # @param [String] uri
  # @param [String] response_fixture filename
  def stub(http_method, uri, response_fixture)
    stub_request(http_method, uri)
      .to_return(
        a_successful_response_with(json_string(response_fixture))
      )
  end

  # @param [String] body
  def a_successful_response_with(body)
    {
      status: 200,
      body: body,
      headers: { 'Content-Type' => 'application/json' }
    }
  end
end
