require 'net-ldap'

class Authz

  Net::LDAP::Connection.send(:remove_const, 'LdapVersion')
  Net::LDAP::Connection::LdapVersion = 2

  def test
  #ldap = Net::LDAP.new :host => "ldap.library.upenn.int",
  ldap = Net::LDAP.new :host => "172.16.34.168",
       :auth => {
         :method => :anonymous
       }

  filter = Net::LDAP::Filter.eq( "cn", "test" )
  treebase = "o=PennKey_Proxy_AuthZ_Directory,c=US"

  ldap.search( :base => treebase, :filter => filter ) do |entry|
    puts "DN: #{entry.dn}"
    entry.each do |attribute, values|
      puts "   #{attribute}:"
      values.each do |value|
        puts "      --->#{value}"
      end
    end
  end

  p ldap.get_operation_result

  end
end
