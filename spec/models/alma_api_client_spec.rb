require 'rails_helper'

RSpec.describe AlmaApiClient, type: :model do
  include MockAlmaApi

  let(:api) { described_class.new }
  let(:user) { AlmaUser.new('testuser') }

  before { stub_user_get_success }

  describe '#find_item_for' do
    context 'existing items' do
      let(:request) do
        LocalRequest.new(
          user,
          { local_request: {
            mms_id: '1234', holding_id: '2345', item_pid: '3456'
          } }
        )
      end

      before { stub_item_get_success }

      it 'find existing items' do
        item = api.find_item_for request
        expect(item).to be_a Alma::BibItem
        expect(item.pid).to eq '3456'
      end
    end

    context 'non-existent items' do
      let(:bad_request) do
        LocalRequest.new(
          user,
          { local_request: {
            mms_id: '1234', holding_id: '2345', item_pid: '9876'
          } }
        )
      end
      before { stub_item_get_failure }
      it 'raises exception if item not found' do
        expect { api.find_item_for(bad_request) }.to(
          raise_error(AlmaApiClient::ItemNotFound)
        )
      end
    end
  end
  describe '#create_item_request' do
    context 'successfully' do
      let(:request) do
        LocalRequest.new(
          user,
          { local_request: {
            mms_id: '1234', holding_id: '2345', item_pid: '3456',
            pickup_location: 'TestLib', comments: 'Blah blah'
          } }
        )
      end
      before { stub_request_post_success }
      it 'sends request to alma_api and receives a success indicator' do
        response = api.create_item_request(request)
        expect(response).to be true
      end
    end
    context 'with errors' do
      let(:request) do
        LocalRequest.new(
          user,
          { local_request: {
            mms_id: '1234', holding_id: '2345', item_pid: '9876',
            pickup_location: 'TestLib', comments: 'Blah blah'
          } }
        )
      end
      before { stub_request_post_failure }
      it 'raises an exception if item not found' do
        expect { api.create_item_request(request) }.to(
          raise_error(AlmaApiClient::RequestFailed)
        )
      end
    end
  end
end