# frozen_string_literal: true

# Handle browser requests for a request
class RequestController < ApplicationController
  include AlmaUserLookup

  rescue_from AlmaApiClient::Timeout do |exception|
    redirect(exception.message)
  end

  # show the form
  def new
    @record = if params[:mms_id]
                # local request case...
                ParallelAlmaApi.new params[:mms_id], @user.pennkey
              else
                # any other case - e.g., OpenURL params for ILL/Resource Sharing request
                nil
              end

  end

  # submit the request
  def create

  end

  # show confirmation
  def show;  end

  # example links for testing/demos
  def test; end

  private

  # @return [TrueClass, FalseClass]
  def mms_id_present?
    params.include? :mms_id
  end
end
