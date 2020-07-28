require 'rails_helper'

RSpec.describe User, type: :model do
  subject { User.new('bfranklin', pcom_service: pcom_service) }

  def mock_service_response(data, pcom_service)
    allow(pcom_service).to receive(:lookup).and_return data
  end

  let(:pcom_service) { class_double PennCommunity }
  let :pcom_service_response do
    {
        'penn_id' => '12345678',
        'affiliation_active_code' => ['A'],
        'affiliation_code' => ['STAF'],
        'pennkey_active_code' => 'A',
        'pennkey' => 'bfranklin',
        'first_name' => 'Ben',
        'middle_name' => '',
        'last_name' => 'Franklin',
        'email' => 'bfranklin@upenn.edu',
        'org_active_code' => ['A-F'],
        'org_code' => ['5008'],
        'dept' => ['Library Computing Systems'],
        'rank' => ['Staff']
    }
  end

  before do
    allow_any_instance_of(PennLdapUser).to receive(:standing_faculty?).and_return false
  end

  context 'basic attributes' do
    before do
      mock_service_response pcom_service_response, pcom_service
    end
    it 'has a name' do
      expect(subject.name).to eq 'Ben Franklin'
    end
    it 'has an affiliation' do
      expect(subject.affiliation).to eq 'Library Computing Systems Staff'
    end
    it 'has a data hash' do
      expect(subject.data).to be_a Hash
      expect(subject.data.keys).to include 'status', 'dept', 'proxied_by', 'proxied_for'
    end
  end
  context 'status determination' do
    it 'returns StandingFaculty if LDAP indicates such' do
      mock_service_response pcom_service_response, pcom_service
      allow_any_instance_of(PennLdapUser).to receive(:standing_faculty?).and_return true
      expect(subject.data['status']).to eq 'StandingFaculty'
    end
    it 'ignores inactive affiliation codes' do
      pcom_service_response['affiliation_active_code'] << 'I' # TODO: is it I for inactive??
      pcom_service_response['affiliation_code'] << 'FAC'
      mock_service_response pcom_service_response, pcom_service
      expect(subject.data['status']).to eq 'Staff'
    end
    it 'is FAC if user is faculty' do
      pcom_service_response['affiliation_active_code'] << 'A'
      pcom_service_response['affiliation_code'] << 'FAC'
      mock_service_response pcom_service_response, pcom_service
      expect(subject.data['status']).to eq 'Faculty'
    end
    it 'is other if user is other' do
      pcom_service_response['affiliation_active_code'] << 'A'
      pcom_service_response['affiliation_code'] << 'CHOP'
      mock_service_response pcom_service_response, pcom_service
      expect(subject.data['status']).to eq 'CHOP'
    end
    it 'is STU if only STU is present' do
      pcom_service_response['affiliation_code'] = ['STU']
      mock_service_response pcom_service_response, pcom_service
      expect(subject.data['status']).to eq 'Student'
    end
    it 'is STAF if only STAF is present' do
      pcom_service_response['affiliation_code'] = ['STAF']
      mock_service_response pcom_service_response, pcom_service
      expect(subject.data['status']).to eq 'Staff'
    end
  end
end
