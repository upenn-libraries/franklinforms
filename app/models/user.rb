class User

  attr_accessor :data

  def initialize(id, proxy_id = nil)
    begin
      @data = PennCommunity.getUser(proxy_id || id)
      @data['proxied_by'] = id
      @data['proxied_for'] = proxy_id || id
      setStatus
    rescue StandardError => e
      ExceptionNotifier.notify_exception(
        StandardError.new(
          "Problem initializing User object! id is #{id} and proxy_id is #{proxy_id}. Original Exception message is: #{e.message} "
        )
      )
      @data = { 'username' => id }
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

  # Return 'proxied_for' value, or the current user's id
  # @return [String] proxied_for username
  def proxied_for
    @data['proxied_for'] || id
  end

  def id
    @data['username']
  end

  # Merge/overwrite data returned from ILLiad DB query into this User object. In the past, this was done in the
  # Illiad#getIlliadUserInfo method
  # data looks like:
  # {:emailaddress=>"mail@upenn.edu",
  #  :phone=>"8563710713",
  #  :department=>"Other - Unlisted",
  #  :nvtgc=>"ILL",
  #  :address=>"3420 Walnut St",
  #  :address2=>nil,
  #  :status=>"Staff",
  #  :cleared=>"Yes",
  #  :ill_office=> 'VPL',
  #  :ill_office_name=> ''}
  # @param [Hash] data
  # @return [User]
  def merge_ill_data(data)
    if data.nil?
      #  No ILLiad record for this user
      @data['illiadrecord'] = 'new'
      @data['illoffice'] = data[:ill_office]
    elsif ill_needs_updating?(data)
      # ILLiad record exists - mark user data for updating the ILLiad record
      @data['illiadrecord'] = 'modify'
      @data['dept'] = data[:department]
      # set ill office, prefer nvtgc value from illiad over inferred value from org code
      @data['illoffice'] = data[:nvtgc] || data[:ill_office]
      # set new values here or fallback to existing
      @data['delivery'] = data[:address] || @data['delivery']
      @data['status'] = data[:status] || @data['status']
    else
      # mark user as not needing updating in ILLiad
      @data['illiadrecord'] = 'nochange'
    end
    self
  end

  private

  # Check some fields from ILL to see if they don't match what we already have
  # TODO: is @data['illoffice'] ever already set?
  # @param [Hash] ill_data
  # @return [TrueClass, FalseClass]
  def ill_needs_updating?(ill_data)
    @data['dept'] != ill_data[:department] ||
      @data['illoffice'] != ill_data[:nvtgc] ||
      @data['status'] != ill_data[:status] ||
      @data['emailAddr'] != ill_data[:emailaddress] ||
      @data['phone'] != ill_data[:phone]
  end
end
