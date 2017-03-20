class User

  attr_accessor :data

  def initialize(id, proxy_id = nil)
    @data = PennCommunity.getUser(id)
    @data['proxied_by'] = id
    @data['proxied_for'] = proxy_id || id
    setStatus
  end

  def setStatus
    @data['affiliation_active_code'].zip(@data['affiliation_code']).each {|affl|
      active, code = affl

      if active == 'A'
        case code
          when 'FAC'
            @data['status'] = 'Faculty'
          when 'STU'
            @data['status'] ||= 'Student'
          when 'STAF'
            @data['status'] ||= 'Staff'
          else
            @data['status'] = code
        end
      end

      @data['status'] ||= ''
    }
  end

  def name
    return [@data['first_name'], @data['middle_name'], @data['last_name']].join(' ').squeeze(' ').strip()
  end

  def affiliation
    return [@data['dept'], @data['status']].join(' ').squeeze(' ').strip()
  end

<<DOC
sub getUserStatus
{
    my @affls_active = split /\|/, $userInfo{'affiliation_active_code'};
    my @affls        = split /\|/, $userInfo{'affiliation'};

    for ( my $i = 0; $i < scalar(@affls); $i++ ) {

        if ( $affls_active[$i] eq 'A' ) {

            if ( $affls[$i] eq 'FAC' ) {
                $userInfo{'status'} = 'Faculty';

            } elsif ( $affls[$i] eq 'STU'  and !$userInfo{'status'} ) {
                $userInfo{'status'} = 'Student';

            } elsif ( $affls[$i] eq 'STAF' and !$userInfo{'status'} ) {
                $userInfo{'status'} = 'Staff';

            } else {
                $userInfo{'status'} = $affls[$i];
            }

        }

    }


    $userInfo{'status'} = 'StandingFaculty' if $userInfo{'proxiedby'} eq 'schultz2';

}
DOC
  
end
