require 'net-ldap'

# user attribute checks via LDAP
class PennLdapUser

  # TODO: relocate to ENV?
  LDAP_HOST = '172.16.34.168'.freeze

  # Force Net::LDAP to use LDAP v2
  Net::LDAP::Connection.send(:remove_const, 'LdapVersion')
  Net::LDAP::Connection::LdapVersion = 2

  def initialize(username)
    @base_filter = Net::LDAP::Filter.eq('cn', username)
  end

  # Checks if username exists in LDAP
  # TODO: this is never used. perhaps a relic from HTTP basic auth days?
  # @param [Net::LDAP] ldap
  # @return [TrueClass, FalseClass]
  def authorized?(ldap = establish_anonymous_conn)
    treebase = 'o=PennKey_Proxy_AuthZ_Directory,c=US'
    results = ldap.search base: treebase, filter: @base_filter
    results.any?
  end

  # Check if username is Standing Faculty?
  # @param [Net::LDAP] ldap
  # @return [TrueClass, FalseClass]
  def standing_faculty?(ldap = establish_anonymous_conn)
    filters = @base_filter & Net::LDAP::Filter.eq('ou', 'fdd')
    results = ldap.search base: 'o=libpatrons,dc=library,dc=upenn,dc=edu', filter: filters
    results.any?
  end

  private

  def establish_anonymous_conn
    Net::LDAP.new host: LDAP_HOST, auth: { method: :anonymous }
  end

  def establish_authorized_conn
    Net::LDAP.new host: LDAP_HOST, auth: { method: :simple,
                                           username: 'cn=manager,o=libpatrons,dc=library,dc=upenn,dc=edu',
                                           password: ENV['PENN_LDAP_PASSWORD'] }
  end

end
