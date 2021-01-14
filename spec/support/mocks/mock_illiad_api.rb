module MockIlliadApi
  include JsonFixtures
  def stub_transaction_post_success
    stub_request(:post, "#{ENV['ILLIAD_API_BASE_URI']}/transaction")
      .with(
        body: book_transaction_data,
        headers: default_headers
      ).to_return(
        status: 200, body: json_string('illiad/transaction_post_success.json'), headers: {}
      )
  end

  def stub_user_get_success
    stub_request(:get, "#{ENV['ILLIAD_API_BASE_URI']}/users/testuser")
      .with(headers: default_headers)
      .to_return(status: 200, body: json_string('illiad/user_success_response.json'), headers: {})
  end

  def stub_user_post_success
    stub_request(:post, "#{ENV['ILLIAD_API_BASE_URI']}/users")
      .with(
        body: "Username=testuser&LastName=User&FirstName=Test&EMailAddress=testuser%40upenn.edu&NotificationPreferences[][ActivityType]=ClearedUser&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=PasswordReset&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=RequestCancelled&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=RequestOther&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=RequestOverdue&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=RequestPickup&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=RequestShipped&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=RequestElectronicDelivery&NotificationPreferences[][NotificationType]=Email",        headers: default_headers
      ).to_return(
        status: 200, body: json_string('illiad/user_success_response.json'), headers: {}
      )
  end

  private

  def book_transaction_data
    '{"Username":"testuser","ProcessType":"Borrowing","LoanAuthor":"B Franklin","LoanTitle":"Autobiography","LoanPublisher":"Penn Press","LoanPlace":"Philadelphia, PA","LoanDate":"2020","LoanEdition":null,"ISSN":null,"ESPNumber":null,"Notes":null,"CitedIn":null,"ItemInfo1":"test"}'
  end

  def default_headers
    { 'Accept' => 'application/json; version=1',
      'Apikey' => ENV['ILLIAD_API_KEY'] }
  end
end
