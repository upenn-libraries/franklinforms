class LocalRequestsController < ApplicationController
  helper LocalRequestsHelpers

  before_action :set_user

  # show the form
  def new
    @delivery_options = ['PickUp@Penn', 'Books by Mail', 'Digital Delivery']
    @local_request = LocalRequest.new params, @user
  end

  # submit the request
  def create

  end

  # show confirmation
  def show

  end

  private

  # @return [User]
  def set_user
    @user = User.new helpers.username_from_headers
  end
end
