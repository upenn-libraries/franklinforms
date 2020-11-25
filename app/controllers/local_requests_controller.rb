class LocalRequestsController < ApplicationController
  # show the form
  def show
    @delivery_options = ['PickUp@Penn', 'Books by Mail', 'Digital Delivery']
    @local_request = LocalRequest.new params
  end

  # submit the request
  def create

  end
end
