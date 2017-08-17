require 'net-ldap'

class PennLdap

  Net::LDAP::Connection.send(:remove_const, 'LdapVersion')
  Net::LDAP::Connection::LdapVersion = 2

  def self.authorize(username)
    #ldap = Net::LDAP.new :host => "ldap.library.upenn.int",
    ldap = Net::LDAP.new :host => "172.16.34.168",
         :auth => {
           :method => :anonymous
         }
  
    filter = Net::LDAP::Filter.eq( "cn", username )
    treebase = "o=PennKey_Proxy_AuthZ_Directory,c=US"
  
    results = ldap.search( :base => treebase, :filter => filter )
  
    return results.size > 0

  end

  def self.isStandingFaculty(username)
    ldap = Net::LDAP.new :host => "172.16.34.168",
         :auth => {
           :method => :simple,
           :username => "cn=manager,o=libpatrons,dc=library,dc=upenn,dc=edu",
           :password => ENV['PENN_LDAP_PASSWORD']
         }

    filter = Net::LDAP::Filter.eq("cn", username) & Net::LDAP::Filter.eq("ou", "fdd")
    treebase = "o=libpatrons,dc=library,dc=upenn,dc=edu"

    results = ldap.search( :base => treebase, :filter => filter )

    return results.size > 0
  end

end
