# sort the wheat from the chaff in Alma's User API response
class AlmaUser
  attr_reader :id, :name, :email, :user_group, :affiliation,
              :organization, :active

  # @param [String] user_id
  # @return [AlmaUser]
  def initialize(user_id)
    user_record = get_user user_id
    @id = user_record.id
    @name = user_record.full_name
    @email = user_record.preferred_email
    @user_group = user_group_from user_record
    @affiliation = affiliation_from user_record
    @organization = organization_from user_record
    @active = active_from user_record
  end

  # @return [Hash{Symbol->Unknown}]
  def to_h
    { id: id, name: name, email: email, user_group: user_group,
      affiliation: affiliation, organization: organization }
  end

  private

  # @param [String] user_id
  def get_user(user_id)
    Alma::User.find user_id
  end

  def user_group_from(user_record)
    user_record.user_group['desc']
  end

  def affiliation_from(user_record)
    affiliation_stat = user_record.user_statistic&.find do |stat|
      stat.dig('category_type', 'value') == 'AFFILIATION'
    end
    affiliation_stat&.dig 'statistic_category', 'desc'
  end

  def organization_from(user_record)
    organization_stat = user_record.user_statistic&.find do |stat|
      stat.dig('category_type', 'value') == 'ORG'
    end
    organization_stat&.dig 'statistic_category', 'desc'
  end

  def active_from(user_record)
    user_record.status.dig('value') == 'ACTIVE'
  end
end