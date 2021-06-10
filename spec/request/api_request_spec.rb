# frozen_string_literal: true

RSpec.describe 'Franklinforms API', type: :request do
  context 'without auth token' do
    it 'returns an unauthorized status' do
      get '/forms/api/user/testuser/info'
      expect(response).to have_http_status :unauthorized
    end
  end
  context 'with auth token' do
    let(:headers) { { 'X-User-Token' => token_value } }
    context 'that is valid' do
      let(:token_value) { 'valid_token' }
      let(:user_info) do
        { 'penn_id' => '12345678', 'affiliation_active_code' => ['A'],
          'affiliation_code' => ['STAF'], 'pennkey_active_code' => 'A',
          'pennkey' => 'testuser', 'first_name' => 'Test', 'middle_name' => '',
          'last_name' => 'User', 'email' => 'testuser@upenn.edu',
          'org_active_code' => ['A-F'], 'org_code' => ['5008'],
          'dept' => ['Library Computing Systems'], 'rank' => ['Staff'] }
      end
      before do
        allow(PennCommunity).to receive(:getUser).and_return user_info
        ENV['USER_API_ACCESS_TOKEN'] = token_value
      end
      context 'with endpoint enabled via ENV var' do
        before do
          ENV['ENABLE_USERINFO_ENDPOINT'] = 'true'
        end
        it 'returns a hash of user data from PennCommunity' do
          get '/forms/api/user/testuser/info', headers: headers
          parsed_response = JSON.parse response.body
          expect(parsed_response).to eq user_info
        end
        context 'but an invalid PennKey' do
          let(:pennkey) { 'not-a-valid-1' }
          it 'returns a bad request status' do
            get "/forms/api/user/#{pennkey}/info", headers: headers
            expect(response).to have_http_status :bad_request
          end
        end
      end
      context 'but endpoint disabled via ENV var' do
        before do
          ENV['ENABLE_USERINFO_ENDPOINT'] = 'true'
        end
        it 'returns an OK status' do
          get '/forms/api/user/testuser/info', headers: headers
          expect(response).to have_http_status :ok
        end
      end
    end
    context 'that is invalid' do
      let(:token_value) { 'bad_token' }
      before do
        ENV['ENABLE_USERINFO_ENDPOINT'] = 'true'
        ENV['USER_API_ACCESS_TOKEN'] = 'valid_token'
      end
      it 'returns an unauthorized status' do
        get '/forms/api/user/testuser/info', headers: headers
        expect(response).to have_http_status :unauthorized
      end
    end
  end
  after do
    ENV['ENABLE_USERINFO_ENDPOINT'] = nil
    ENV['USER_API_ACCESS_TOKEN'] = nil
  end
end
