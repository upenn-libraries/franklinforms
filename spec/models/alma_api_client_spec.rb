require 'rails_helper'

RSpec.describe AlmaApiClient, type: :model do
  include MockAlmaApi
  include AlmaSpecHelpers

  let(:api) { described_class.new }
  let(:user) { AlmaUser.new('testuser') }

  # TODO: mock user object
  before { stub_alma_user_get_success }

  describe '#find_item_for' do
    context 'existing items' do
      let(:request) { LocalRequest.new(user, item_identifiers) }
      before { stub_item_get_success }

      it 'find existing items' do
        item = api.find_item_for(
          mms_id: request.mms_id, holding_id: request.holding_id,
          item_pid: request.item_pid
        )
        expect(item).to be_a Alma::BibItem
        expect(item.pid).to eq '3456'
      end
    end

    context 'non-existent items' do
      let(:bad_request) do
        LocalRequest.new(
          user,
          item_identifiers(item_pid: '9876') # overwrite item_pid
        )
      end
      before { stub_item_get_failure }
      it 'raises exception if item not found' do
        expect { api.find_item_for(bad_request.identifiers) }.to(
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
          item_identifiers(pickup_location: 'TestLib', comments: 'Blah blah')
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
          item_identifiers(item_pid: '9876', pickup_location: 'TestLib',
                           comments: 'Blah blah')
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