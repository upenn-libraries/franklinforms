require 'rails_helper'

RSpec.describe PennCommunity, type: :model do
  let(:service) { PennCommunity }
  context '#user_info_for' do
    context 'error conditions' do
      it 'raises an exception if no username param' do
        expect { service.get_user_info(nil) }.to raise_exception StandardError
      end
      it 'raises an exception if an invalid username is provided' do
        expect { service.get_user_info('username10') }.to raise_exception StandardError
      end
    end
  end
end
