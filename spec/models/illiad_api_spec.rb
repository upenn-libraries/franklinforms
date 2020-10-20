require 'rails_helper'

RSpec.describe IlliadApi, type: :model do
  let(:api) { IlliadApi.new }
  context 'version' do
    it 'returns the Illiad API version' do
      response = api.version
      expect(response.body).to include 'Current API Version: 1'
    end
  end
  context 'secure version' do
    it 'returns the secure platform version' do
      response = api.secure_version
      expect(response.body).to include 'ILLiad Secure Platform Version: 9.0.1.0'
    end
  end
  context 'api submit' do
    let(:user) do
      { 'proxied_for' => 'bfranklin' }
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
      body = Illiad.book_request_body user, bib_data_book, 'test'
      # response = api.transaction body # TODO: mock
      expect(response).to not_be nil
    end
  end
end