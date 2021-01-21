require 'rails_helper'

RSpec.describe AlmaRecord, type: :model do
  include MockAlmaApi

  let(:user) { AlmaUser.new('testuser') }

  before { stub_user_get_success }

  context "validations" do
    let(:request) { LocalRequest.new(user) }
    it 'requires a requestor_email value to be present' do
      request.valid?
      expect(request.errors.details).to have_key :requestor_email
      expect(request.errors.details[:requestor_email].first[:error]).to eq :blank
    end
    it 'requires a delivery_method value to be present' do
      request.valid?
      expect(request.errors.details).to have_key :delivery_method
      expect(request.errors.details[:delivery_method].first[:error]).to eq :blank
    end
    context 'for scandeliver request' do
      let(:scandeliver_request) do
        LocalRequest.new user,
                         { delivery_method: 'scandeliver' }
      end
      it 'requires additional field values to be present' do
        scandeliver_request.valid?
        expect(scandeliver_request.errors.details.keys).to include :section_title, :section_author
        expect(scandeliver_request.errors.details[:section_title].first[:error]).to eq :blank
        expect(scandeliver_request.errors.details[:section_author].first[:error]).to eq :blank
      end
    end
    context 'for supported delivery methods' do
      before { stub_item_get_success }
      let(:scandeliver_request) do
        request = LocalRequest.new(
          user, mms_id: '1234', holding_id: '2345', item_pid: '3456',
          delivery_method: 'horseandbuggy'
        )
        request.bib_item = AlmaApiClient.new.find_item_for request
        request
      end
      it 'requires the delivery method to be in the item\'s set of supported delivery methods' do
        scandeliver_request.valid?
        expect(scandeliver_request.errors.details).to have_key :delivery_method
        expect(scandeliver_request.errors.details[:delivery_method].first[:error]).to eq :inclusion
      end
    end
  end
end