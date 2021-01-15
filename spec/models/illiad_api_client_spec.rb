require 'rails_helper'

RSpec.describe IlliadApiClient, type: :model do
  include MockIlliadApi
  let(:api) { described_class.new }
  context 'api book request submit' do
    let(:user) do
      OpenStruct.new data: { 'proxied_for' => 'testuser' }
    end
    context 'success' do
      let(:bib_data_book) do
        {
          'author' => 'B Franklin',
          'booktitle' => 'Autobiography',
          'publisher' => 'Penn Press',
          'place' => 'Philadelphia, PA',
          'year' => '2020'
        }
      end
      it 'returns a transaction number' do
        stub_transaction_post_success
        body = Illiad.book_request_body user, bib_data_book, 'test'
        response = api.transaction body
        expect(response).to eq '123456'
      end
    end
    context 'failure' do
      it 'fails' do
        stub_transaction_post_failure
        body = 'invalid-json'
        expect {
          api.transaction body
        }.to raise_error IlliadApiClient::RequestFailed
      end
    end
  end
  context 'user' do
    let(:user_info) do
      {
        'Username' => 'testuser',
        'LastName' => 'User',
        'FirstName' => 'Test',
        'EMailAddress' => 'testuser@upenn.edu',
        'NVTGC' => 'VPL'
      }
    end
    context 'lookup' do
      context 'success' do
        it 'returns user info' do
          stub_user_get_success
          response = api.get_user 'testuser'
          expect(response&.keys).to include :username, :emailaddress
        end
      end
      context 'failure' do
        it 'raises an exception' do
          stub_user_get_failure
          expect {
            api.get_user 'irrealuser'
          }.to raise_error IlliadApiClient::UserNotFound
        end
      end
    end
    context 'create' do
      context 'success' do
        it 'returns newly created user info' do
          stub_user_post_success
          response = api.create_user user_info
          expect(response&.dig(:username)).to eq 'testuser'
        end
      end
      context 'failure' do
        it 'raises an InvalidRequest exception if user data is invalid' do
          expect {
            api.create_user({})
          }.to raise_error IlliadApiClient::InvalidRequest
        end
        it 'raises an InvalidRequest exception if response code indicates invalidity' do
          stub_user_post_failure
          expect {
            api.create_user({ "Username": "test" })
          }.to raise_error IlliadApiClient::InvalidRequest
        end
      end
    end
  end
end