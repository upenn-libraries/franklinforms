require 'rails_helper'

RSpec.describe IlliadApi, type: :model do
  include IlliadApiMocks
  let(:api) { IlliadApi.new }
  context 'api book request submit' do
    let(:user) do
      OpenStruct.new data: { 'proxied_for' => 'bfranklin' }
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
      stub_book_transaction
      body = Illiad.book_request_body user, bib_data_book, 'test'
      response = api.transaction body
      expect(response).to eq '123456'
    end
  end
  context 'user' do
    context 'lookup' do
      it 'returns user info' do
        stub_get_user_transaction
        response = api.user_info 'testuser'
        expect(response.keys).to include 'UserName', 'EMailAddress'
      end
    end
    context 'update' do

    end
    context 'create' do

    end
  end
end