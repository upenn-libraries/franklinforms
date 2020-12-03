# sort the wheat from the chaff in Alma's (brief) User API response
class AlmaUser
  attr_reader :name, :email, :user_group, :affiliation, :organization, :active

  # @param [String] user_id
  def initialize(user_id)
    api_response = get_brief_user_details user_id
    @name = name_from api_response
    @email = email_from api_response
    @user_group = user_group_from api_response
    @affiliation = affiliation_from api_response
    @organization = organization_from api_response
    @active = active_from api_response
  end

  private

  # @param [String] user_id
  def get_brief_user_details(user_id)
    user_api_uri = Alma::User.resources.almaws_v1_users.user_id.uri_template(user_id: user_id).chomp('/')
    response = HTTParty.get "#{user_api_uri}?view=brief&apikey=#{ENV['ALMA_API_KEY']}"
    response.parsed_response['user']
  end

  def name_from(api_response)
    api_response['full_name']
  end

  def email_from(api_response)
    emails = api_response.dig 'contact_info', 'emails'
    preferred_email = emails.find do |_, email_info|
      email_info['preferred'] == 'true'
    end
    preferred_email[1].dig 'email_address'
  end

  def user_group_from(api_response)
    api_response.dig 'user_group', 'desc'
  end

  def affiliation_from(api_response)
    affiliation_stat = api_response.dig('user_statistics', 'user_statistic')&.find do |stat|
      stat.dig('category_type', '__content__') == 'AFFILIATION'
    end
    affiliation_stat&.dig 'statistic_category', 'desc'
  end

  def organization_from(api_response)
    organization_stat = api_response.dig('user_statistics', 'user_statistic')&.find do |stat|
      stat.dig('category_type', '__content__') == 'ORG'
    end
    organization_stat&.dig 'statistic_category', 'desc'
  end

  def active_from(api_response)
    api_response.dig('status', '__content__') == 'ACTIVE'
  end
end