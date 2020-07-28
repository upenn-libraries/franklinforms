# represent a user
# used in most forms
# TODO: extend or inherit from OpenStruct to provide a better interface than the @data hash?
class User

  attr_accessor :data

  # @param [String] id of form user
  # @param [Hash] options
  def initialize(id, options = {})
    proxy_id = options[:proxy_id]
    pcom = options[:pcom_service] || PennCommunity
    begin
      @data = pcom.lookup(proxy_id || id)
      @data['status'] = determine_status # can only determine status if we have PCOM data
    rescue StandardError => e
      ExceptionNotifier.notify_exception e
      @data = {}
    end
    @data['proxied_by'] = id
    @data['proxied_for'] = proxy_id || id
  end

  def name
    [@data['first_name'], @data['middle_name'], @data['last_name']].join(' ').squeeze(' ').strip
  end

  def affiliation
    [@data['dept'], @data['status']].join(' ').squeeze(' ').strip
  end

  private

  def determine_status
    return 'StandingFaculty' if PennLdapUser.new(@data['proxied_for']).standing_faculty?

    status = nil
    # e.g., "affiliation_active_code"=>["A"], "affiliation_code"=>["STAF"]
    @data['affiliation_active_code'].zip(@data['affiliation_code']).each do |affiliation|
      active, code = affiliation
      next unless active == 'A'

      case code
      when 'FAC'
        status = 'Faculty'
      when 'STU'
        status ||= 'Student'
      when 'STAF'
        status ||= 'Staff' # TODO: should Staff take precedence over Student?
      else
        status = code
      end
    end
    status
  end
end
