module AlmaUserLookup
  extend ActiveSupport::Concern

  private

  def set_user
    @user = AlmaUser.new helpers.username_from_headers
  end
end