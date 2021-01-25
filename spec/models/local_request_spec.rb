require 'rails_helper'

RSpec.describe LocalRequest, type: :model do
  include MockAlmaApi
  include MockIlliadApi
  include AlmaSpecHelpers

  let(:user) { AlmaUser.new('testuser') }

  before { stub_alma_user_get_success }

  context 'submission' do
    context 'via ILLiad API' do
      let(:api) { IlliadApiClient.new }
      context 'success' do
        context 'BBM' do
          before do
            stub_item_get_success
            stub_transaction_post_success
          end
          let(:local_request) do
            LocalRequest.new(
              user,
              item_identifiers(delivery_method: 'booksbymail', requestor_email: user.email)
            )
          end
          it 'submits and returns a transaction code' do
            expect(local_request.submit).to eq '123456'
          end
        end
      end
      context 'failure' do

      end
    end
    context 'via Alma API' do
      context 'success' do

      end
      context 'failure' do

      end
    end
  end

  context "validations" do
    before { stub_item_get_success }
    let(:request) { LocalRequest.new(user, item_identifiers) }
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
    context 'for the bib_item' do
      let(:malformed_request) { LocalRequest.new user } # no identifiers
      it 'requires valid alma item identifiers' do
        expect {
          malformed_request.bib_item
        }.to raise_error ArgumentError, 'Insufficient identifiers set'
      end
    end
    context 'for scandeliver request' do
      let(:scandeliver_request) do
        LocalRequest.new user, item_identifiers(delivery_method: 'scandeliver')
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
        LocalRequest.new(user,
                         item_identifiers(delivery_method: 'horseandbuggy'))
      end
      it 'requires the delivery method to be in the item\'s set of supported delivery methods' do
        scandeliver_request.valid?
        expect(scandeliver_request.errors.details).to have_key :delivery_method
        expect(scandeliver_request.errors.details[:delivery_method].first[:error]).to eq :inclusion
      end
    end
  end
end