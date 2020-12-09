module IlliadApiMocks
  def mock_book_transaction
    stub_request(:post, "#{ENV['ILLIAD_API_BASE_URI']}/transaction")
      .with(
        body: submit_book_transaction_data.to_param,
        headers: default_headers
      ).to_return(
        status: 200, body: book_transaction_request_response, headers: {}
      )
  end

  def submit_book_transaction_data
    {
      "Username" => 'testuser',
      "ProcessType" => "Borrowing",
      "LoanAuthor" => "B Franklin",
      "LoanTitle" => "Autobiography",
      "LoanPublisher" => "Penn Press",
      "LoanPlace" => "Philadelphia, PA",
      "LoanDate" => "2020",
      "LoanEdition" => "",
      "ISSN" => "",
      "ESPNumber" => "",
      "Notes" => "",
      "CitedIn" => "",
      "ItemInfo1" => "test"
    }
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
      "SSN": "22222222",
      "Status": "Staff",
      "EMailAddress": "testuser@upenn.edu",
      "Phone": "9042411080",
      "Department": "Other - Unlisted",
      "NVTGC": "VPL",
      "NotificationMethod": "Electronic",
      "DeliveryMethod": "Mail to Address",
      "LoanDeliveryMethod": "Hold for Pickup",
      "LastChangedDate": "2020-12-24T12:12:12",
      "AuthorizedUsers": nil,
      "Cleared": "Yes",
      "Web": true,
      "Address": "123 Main St.",
      "Address2": nil,
      "City": Philadelphia,
      "State": PA,
      "Zip": "19104",
      "Site": nil,
      "ExpirationDate": "2025-12-08T10:50:04",
      "Number": nil,
      "UserRequestLimit": nil,
      "Organization": nil,
      "Fax": nil,
      "ShippingAcctNo": nil,
      "ArticleBillingCategory": "Exempt",
      "LoanBillingCategory": "Exempt",
      "Country": nil,
      "SAddress": nil,
      "SAddress2": nil,
      "SCity": nil,
      "SState": nil,
      "SZip": nil,
      "SCountry": nil,
      "RSSID": "555555555555555555555",
      "AuthType": "ILLiad",
      "UserInfo1": nil,
      "UserInfo2": nil,
      "UserInfo3": nil,
      "UserInfo4": nil,
      "UserInfo5": nil,
      "MobilePhone": nil
    }'
  end
  
  def book_transaction_request_response
    {
      "TransactionNumber" => "1560106",
      "Username" => "mkanning",
      "RequestType" => "Article",
      "LoanAuthor" => "B Franklin",
      "LoanTitle" => "Autobiography",
      "LoanPublisher" => "Penn Press",
      "LoanPlace" => "Philadelphia, PA",
      "LoanDate" => "2020",
      "LoanEdition" => "",
      "PhotoJournalTitle" => nil,
      "PhotoJournalVolume" => nil,
      "PhotoJournalIssue" => nil,
      "PhotoJournalMonth" => nil,
      "PhotoJournalYear" => nil,
      "PhotoJournalInclusivePages" => nil,
      "PhotoArticleAuthor" => nil,
      "PhotoArticleTitle" => nil,
      "CitedIn" => "",
      "CitedTitle" => nil,
      "CitedDate" => nil,
      "CitedVolume" => nil,
      "CitedPages" => nil,
      "NotWantedAfter" => nil,
      "AcceptNonEnglish" => false,
      "AcceptAlternateEdition" => true,
      "ArticleExchangeUrl" => nil,
      "ArticleExchangePassword" => nil,
      "TransactionStatus" => "Awaiting RAPID Request Sending",
      "TransactionDate" => "2020-12-09T14:12:29.86",
      "ISSN" => "",
      "ILLNumber" => nil,
      "ESPNumber" => "",
      "LendingString" => nil,
      "BaseFee" => nil,
      "PerPage" => nil,
      "Pages" => nil,
      "DueDate" => nil,
      "RenewalsAllowed" => false,
      "SpecIns" => nil,
      "Pieces" => nil,
      "LibraryUseOnly" => nil,
      "AllowPhotocopies" => false,
      "LendingLibrary" => nil,
      "ReasonForCancellation" => nil,
      "CallNumber" => nil,
      "Location" => nil,
      "Maxcost" => nil,
      "ProcessType" => "Borrowing",
      "ItemNumber" => nil,
      "LenderAddressNumber" => nil,
      "Ariel" => false,
      "Patron" => nil,
      "PhotoItemAuthor" => nil,
      "PhotoItemPlace" => nil,
      "PhotoItemPublisher" => nil,
      "PhotoItemEdition" => nil,
      "DocumentType" => nil,
      "InternalAcctNo" => nil,
      "PriorityShipping" => nil,
      "Rush" => "Regular",
      "CopyrightAlreadyPaid" => "No",
      "WantedBy" => nil,
      "SystemID" => "OCLC",
      "ReplacementPages" => nil,
      "IFMCost" => nil,
      "CopyrightPaymentMethod" => nil,
      "ShippingOptions" => nil,
      "CCCNumber" => nil,
      "IntlShippingOptions" => nil,
      "ShippingAcctNo" => nil,
      "ReferenceNumber" => nil,
      "CopyrightComp" => nil,
      "TAddress" => nil,
      "TAddress2" => nil,
      "TCity" => nil,
      "TState" => nil,
      "TZip" => nil,
      "TCountry" => nil,
      "TFax" => nil,
      "TEMailAddress" => nil,
      "TNumber" => nil,
      "HandleWithCare" => false,
      "CopyWithCare" => false,
      "RestrictedUse" => false,
      "ReceivedVia" => nil,
      "CancellationCode" => nil,
      "BillingCategory" => nil,
      "CCSelected" => "No",
      "OriginalTN" => nil,
      "OriginalNVTGC" => nil,
      "InProcessDate" => nil,
      "InvoiceNumber" => nil,
      "BorrowerTN" => nil,
      "WebRequestForm" => nil,
      "TName" => nil,
      "TAddress3" => nil,
      "IFMPaid" => nil,
      "BillingAmount" => nil,
      "ConnectorErrorStatus" => nil,
      "BorrowerNVTGC" => nil,
      "CCCOrder" => nil,
      "ShippingDetail" => nil,
      "ISOStatus" => nil,
      "OdysseyErrorStatus" => nil,
      "WorldCatLCNumber" => nil,
      "Locations" => nil,
      "FlagType" => nil,
      "FlagNote" => nil,
      "CreationDate" => "2020-12-09T14:12:29.797",
      "ItemInfo1" => "test",
      "ItemInfo2" => nil,
      "ItemInfo3" => nil,
      "ItemInfo4" => nil,
      "ItemInfo5" => nil,
      "SpecialService" => nil,
      "DeliveryMethod" => nil,
      "Web" => nil,
      "PMID" => nil,
      "DOI" => nil,
      "LastOverdueNoticeSent" => nil,
      "ExternalRequest" => nil
    }
  end

  def default_headers
    { 'Accept'=>'application/json; version=1',
      'Apikey'=>ENV['ILLIAD_API_KEY'] }
  end
end
