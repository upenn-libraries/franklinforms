require 'rails_helper'

RSpec.describe PennLdapUser, type: :model do
  let(:service) { PennLdapUser.new('test_user') }
  let(:ldap) { instance_double 'Net::Ldap' }
  context '#authorized?' do
    it 'returns true if LDAP returns a record at all' do
      ldap = instance_double 'Net::Ldap'
      allow(ldap).to receive(:search).and_return [{}]
      expect(
        service.authorized?(ldap)
      ).to be_truthy
    end
    it 'returns true if LDAP returns no record at all' do
      allow(ldap).to receive(:search).and_return []
      expect(
        service.authorized?(ldap)
      ).to be_falsey
    end
  end
  context '#standing_faculty?' do
    it 'returns true if LDAP returns a record of a standing faculty member' do
      allow(ldap).to receive(:search).and_return [{}]
      expect(
        service.standing_faculty?(ldap)
      ).to be_truthy
    end
    it 'returns false if LDAP returns no record of a standing faculty member' do
      allow(ldap).to receive(:search).and_return []
      expect(
        service.standing_faculty?(ldap)
      ).to be_falsey
    end
  end
end
