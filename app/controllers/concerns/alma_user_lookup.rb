module AlmaUserLookup
  extend ActiveSupport::Concern

  included do
    before_action :set_user
  end

  private

  def set_user
    @user = AlmaUser.new helpers.username_from_headers
  end
end
