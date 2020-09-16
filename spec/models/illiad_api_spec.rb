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
end