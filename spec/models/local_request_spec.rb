require 'rails_helper'

RSpec.describe LocalRequest, type: :model do
  context 'parameter handling' do
    let(:user) { User.new 'test' }
    context 'for request type' do
      it 'prefers request_type over requesttype' do
        params = { request_type: 'book', requesttype: 'article' }
        expect(LocalRequest.new(params, user).type).to eq :book
      end
      it 'maps older request type value ScanDelivery' do
        params = { requesttype: 'ScanDelivery'}
        expect(LocalRequest.new(params, user).type).to eq :scan
      end
    end
  end
end