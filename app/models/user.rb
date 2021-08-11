class User

  attr_accessor :data

  ALMA_FACEX_GROUP_VALUE = 'FacEXP'.freeze

  def initialize(id, proxy_id = nil)
    return dev_test_user_info(id, proxy_id) unless Rails.env.production?

    begin
      @data = PennCommunity.getUser(proxy_id || id)
      setStatus
    rescue StandardError => e
      Honeybadger.notify e
      @data = {}
    end
    set_facex_status
    @data['proxied_by'] = id
    @data['proxied_for'] = proxy_id || id
  end

  def faculty_express?
    url = "#{ENV['ALMA_API_BASE_URL']}/v1/users/#{@data['proxied_for']}?apikey=#{ENV['ALMA_API_KEY']}&user_id_type=all_unique&view=brief&expand=none&format=json"
    resp = HTTParty.get url
    if resp.success?
      JSON.parse(resp.body).dig('user_group', 'value') == ALMA_FACEX_GROUP_VALUE
    else
      false
    end
  end

  def setStatus
    @data['affiliation_active_code'].zip(@data['affiliation_code']).each do |affl|
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
    end
  end

  def name
    [@data['first_name'], @data['middle_name'], @data['last_name']].join(' ').squeeze(' ').strip
  end

  def affiliation
    [@data['dept'], @data['status']].join(' ').squeeze(' ').strip
  end

  def set_facex_status
    @data['status'] = 'StandingFaculty' if faculty_express?
  end

  # Return true if there's a status code indicating an ILL Block
  # @return [TrueClass, FalseClass]
  def ill_block?
    @data['cleared'].in? %w[B BO]
  end

  private

  def dev_test_user_info(id, proxy_id)
    @data = {}
    @data['proxied_by'] = id
    @data['proxied_for'] = proxy_id || id
    set_facex_status
    @data
  end
end
