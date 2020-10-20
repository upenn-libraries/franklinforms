require 'rails_helper'

RSpec.describe IlliadApi, type: :model do
  include IlliadApiMocks
  let(:api) { IlliadApi.new }
  context 'api submit' do
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
    it 'works' do
      stub_book_transaction
      body = Illiad.book_request_body user, bib_data_book, 'test'
      response = api.transaction body
      expect(response).to eq '123456'
    end
  end
end