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
end
