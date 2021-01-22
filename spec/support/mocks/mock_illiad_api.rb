module MockIlliadApi
  include JsonFixtures
  def stub_transaction_post_success
    stub_request(:post, "#{ENV['ILLIAD_API_BASE_URI']}/transaction")
      .with(
        body: json_string('illiad/transaction_post_body.json'),
        headers: default_headers
      ).to_return(
        status: 200,
        body: json_string('illiad/transaction_post_success.json'),
        headers: {}
      )
  end

  def stub_transaction_post_failure
    stub_request(:post, "#{ENV['ILLIAD_API_BASE_URI']}/transaction")
      .with(
        body: "\"invalid-json\"",
        headers: default_headers
      ).to_return(
        status: 400,
        body: json_string('illiad/transaction_post_failure.json'),
        headers: {}
      )
  end

  def stub_illiad_user_get_success
    stub_request(:get, "#{ENV['ILLIAD_API_BASE_URI']}/users/testuser")
      .with(
        headers: default_headers
      )
      .to_return(
        status: 200,
        body: json_string('illiad/user_success_response.json'),
        headers: {}
      )
  end

  def stub_illiad_user_get_failure
    stub_request(:get, "#{ENV['ILLIAD_API_BASE_URI']}/users/irrealuser")
      .with(
        headers: default_headers
      )
      .to_return(
        status: 404,
        body: json_string('illiad/user_get_failure.json'),
        headers: {}
      )
  end

  def stub_illiad_user_post_success
    stub_request(:post, "#{ENV['ILLIAD_API_BASE_URI']}/users")
      .with(
        body: json_string('illiad/user_post_body.json'),
        headers: default_headers
      ).to_return(
        status: 200,
        body: json_string('illiad/user_success_response.json'),
        headers: {}
      )
  end

  def stub_illiad_user_post_failure
    stub_request(:post, "#{ENV['ILLIAD_API_BASE_URI']}/users")
      .with(
        body: "{ \"Username\":\"value\" }",
        headers: default_headers
      ).to_return(
      status: 400,
      body: '',
      headers: {}
    )
  end

  private

  def default_headers
    { 'Accept' => 'application/json; version=1',
      'Apikey' => ENV['ILLIAD_API_KEY'] }
  end
end
