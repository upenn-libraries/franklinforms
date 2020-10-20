class User

  attr_accessor :data

  def initialize(id, proxy_id = nil)
    begin
      @data = PennCommunity.getUser(proxy_id || id)
      @data['proxied_by'] = id
      @data['proxied_for'] = proxy_id || id
      setStatus
    rescue StandardError => e
      Honeybadger.notify e
      @data = Hash.new
    end
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

      @data['status'] = 'StandingFaculty' if PennLdap.isStandingFaculty(@data['proxied_for'])

      @data['status'] ||= ''
    }
  end

  def name
    return [@data['first_name'], @data['middle_name'], @data['last_name']].join(' ').squeeze(' ').strip()
  end

  def affiliation
    return [@data['dept'], @data['status']].join(' ').squeeze(' ').strip()
  end

  # Return true if there's a status code indicating an ILL Block
  # @return [TrueClass, FalseClass]
  def ill_block?
    @data['cleared'].in? %w[B BO]
  end

  # Is this user currently engaged in a proxied request?
  # @return [TrueClass, FalseClass]
  def proxy_request?
    data['proxied_by'] != data['proxied_for']
  end
end
