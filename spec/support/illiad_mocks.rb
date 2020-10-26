module IlliadApiMocks
  def stub_book_transaction
    stub_request(:post, "https://illiad.library.upenn.edu/ILLiadWebPlatform/transaction").
      with(
          body: "Username=bfranklin&ProcessType=Borrowing&LoanAuthor=B%20Franklin&LoanTitle=Autobiography&LoanPublisher=Penn%20Press&LoanPlace=Philadelphia%2C%20PA&LoanDate=2020&LoanEdition=&ISSN=&ESPNumber=&Notes=&CitedIn=&ItemInfo1=test",
          headers: {
              'Accept'=>'application/json; version=1',
              'Apikey'=>ENV['ILLIAD_API_KEY']
          }).
      to_return(
        status: 200, body: '{"TransactionNumber": "123456"}', headers: {}
      )
  end

  def stub_get_user_transaction
    stub_request(:get, "https://illiad.library.upenn.edu/ILLiadWebPlatform/users/testuser").
      with(
        headers: {
            'Accept'=>'application/json; version=1',
            'Apikey'=>ENV['ILLIAD_API_KEY']
        }).
      to_return(
        status: 200, body: '{
          "UserName": "testuser",
          "ExternalUserId": "testuser",
          "LastName": "User",
          "FirstName": "Test",
          "SSN": "51234567",
          "Status": "Student",
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
          }', headers: {}
        )
  end

  def stub_update_user_transaction

  end

  def stub_create_user_transaction

  end
end
