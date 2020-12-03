class LocalRequestsController < ApplicationController
  helper LocalRequestsHelpers

  before_action :set_user
  before_action :set_availability

  # show the form
  def new
    @delivery_options = ['PickUp@Penn', 'Books by Mail', 'Digital Delivery'] # TODO: delivery options should be tailored to request params
    # @local_request = LocalRequest.new params, @user
    @local_request = LocalRequest.new({}, @user)
  end

  # submit the request
  def create

  end

  # show confirmation
  def show

  end

  # example links for testing/demos
  def test; end

  private

  # @return [AlmaUser]
  def set_user
    # TODO: see Ezwadl Issue #2 - but can we add brief is we use Alma gem wrapper?
    @user = AlmaUser.new helpers.username_from_headers
  end

  def set_availability
    availability_response = Alma::Bib.get_availability(Array.wrap(params[:mms_id]))
    # TODO: narrow response if holding id or item id present
    @availability = availability_response.availability[params[:mms_id]]['holdings']
  end

  # @return [TrueClass, FalseClass]
  def has_alma_identifiers?
    params.key? :mms_id
  end
end
