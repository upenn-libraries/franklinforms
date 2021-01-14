require 'rails_helper'

RSpec.describe IlliadApi, type: :model do
  include MockIlliadApi
  let(:api) { IlliadApi.new }
  context 'api book request submit' do
    let(:user) do
      OpenStruct.new data: { 'proxied_for' => 'testuser' }
    end
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
  context 'user' do
    let(:user_info) do
      {
        'Username' => 'testuser',
        'LastName' => 'User',
        'FirstName' => 'Test',
        'EMailAddress' => 'testuser@upenn.edu'
      }
    end
    context 'lookup' do
      it 'returns user info' do
        stub_user_get_success
        response = api.get_user 'testuser'
        expect(response&.keys).to include :username, :emailaddress
      end
    end
    context 'create' do
      it 'returns newly created user info' do
        stub_user_post_success
        response = api.create_user user_info
        expect(response&.dig(:username)).to eq 'testuser'
      end
    end
  end
end