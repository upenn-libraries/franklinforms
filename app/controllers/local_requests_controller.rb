class LocalRequestsController < ApplicationController
  include AlmaUserLookup

  before_action :redirect, only: :new, unless: :mms_id_present?
  before_action :set_user
  before_action :set_record, only: :new
  before_action :set_request, except: :test

  rescue_from AlmaApiClient::Timeout do |exception|
    redirect(exception.message)
  end

  # show the form
  def new
    @local_request.valid? if params[:has_errors]
  end

  # submit the request
  def create
    if @local_request.valid?
      @local_request.submit
      redirect_to local_requests_path params: @local_request.to_h
    else
      redirect_to new_local_requests_path params: @local_request.to_h
    end
  end

  # show confirmation
  def show
  end

  # example links for testing/demos
  def test; end

  private

  def redirect(message = nil)
    redirect_to new_local_requests_path, flash: { error: message }
  end

  def set_request
    @local_request = LocalRequest.new @user, params
  end

  def set_record
    @record = AlmaRecord.new params[:mms_id].to_s,
                             user_id: @user.id
  end

  # @return [TrueClass, FalseClass]
  def mms_id_present?
    params.include? :mms_id
  end
end
