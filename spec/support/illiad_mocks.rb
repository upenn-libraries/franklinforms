module IlliadApiMocks
  def mock_book_transaction
    stub_request(:post, "#{ENV['ILLIAD_API_BASE_URI']}/transaction")
      .with(
        body: "Username=testuser&ProcessType=Borrowing&LoanAuthor=B%20Franklin&LoanTitle=Autobiography&LoanPublisher=Penn%20Press&LoanPlace=Philadelphia%2C%20PA&LoanDate=2020&LoanEdition=&ISSN=&ESPNumber=&Notes=&CitedIn=&ItemInfo1=test",
        headers: default_headers
      ).to_return(
        status: 200, body: '{"TransactionNumber": "123456"}', headers: {}
      )
  end

  def mock_get_user_transaction
    stub_request(:get, "#{ENV['ILLIAD_API_BASE_URI']}/users/testuser")
      .with(headers: default_headers)
      .to_return(status: 200, body: test_user_response, headers: {})
  end

  def mock_create_user_transaction
    stub_request(:post, "#{ENV['ILLIAD_API_BASE_URI']}/users")
      .with(
        body: "Username=testuser&LastName=User&FirstName=Test&EMailAddress=testuser%40upenn.edu&NotificationPreferences[][ActivityType]=ClearedUser&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=PasswordReset&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=RequestCancelled&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=RequestOther&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=RequestOverdue&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=RequestPickup&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=RequestShipped&NotificationPreferences[][NotificationType]=Email&NotificationPreferences[][ActivityType]=RequestElectronicDelivery&NotificationPreferences[][NotificationType]=Email",        headers: default_headers
      ).to_return(
        status: 200, body: test_user_response, headers: {}
      )
  end

  def test_user_response
    '{
      "UserName": "testuser",
      "ExternalUserId": "testuser",
      "LastName": "User",
      "FirstName": "Test",
      "SSN": "",
      "Status": "",
      "EMailAddress": "testuser@upenn.edu",
      "Phone": "",
      "Department": "",
      "NVTGC": "VPL",
      "NotificationMethod": "Electronic",
      "DeliveryMethod": "Mail to Address",
      "LoanDeliveryMethod": "Hold for Pickup",
      "LastChangedDate": null,
      "AuthorizedUsers": null,
      "Cleared": "Yes",
      "Web": true,
      "Address": "",
      "Address2": null,
      "City": null,
      "State": null,
      "Zip": null,
      "Site": null,
      "ExpirationDate": null,
      "Number": null,
      "UserRequestLimit": null,
      "Organization": null,
      "Fax": null,
      "ShippingAcctNo": null,
      "ArticleBillingCategory": "Exempt",
      "LoanBillingCategory": "Exempt",
      "Country": null,
      "SAddress": null,
      "SAddress2": null,
      "SCity": null,
      "SState": null,
      "SZip": null,
      "SCountry": null,
      "RSSID": "555555555555555555555",
      "AuthType": "Default",
      "UserInfo1": null,
      "UserInfo2": null,
      "UserInfo3": null,
      "UserInfo4": null,
      "UserInfo5": null,
      "MobilePhone": null
    }'
  end

  def default_headers
    { 'Accept'=>'application/json; version=1',
      'Apikey'=>ENV['ILLIAD_API_KEY'] }
  end
end
