# frozen_string_literal: true

# Handle browser requests for Local Requests
class LocalRequestsController < ApplicationController
  include AlmaUserLookup

  before_action :redirect, only: :new, unless: :mms_id_present?
  before_action :set_user
  before_action :set_request, except: :test

  rescue_from AlmaApiClient::Timeout do |exception|
    redirect(exception.message)
  end

  # show the form
  def new
    @record = AlmaRecord.new params[:mms_id].to_s,
                             user_id: @user.id
    @local_request.valid? if params[:has_errors]
  end

  # submit the request
  def create
    if @local_request.valid?
      submission_response = RequestSubmissionService.submit @local_request
      if submission_response[:status] == :success
        redirect_to local_requests_path(params: @local_request.to_h),
                    flash: { success: submission_response[:message] }
      else
        redirect_to new_local_requests_path(params: @local_request.to_h),
                    flash: { error: submission_response[:message] }
      end
    else
      redirect I18n.t('forms.local_request.messages.invalid_request')
    end
  end

  # show confirmation
  def show;  end

  # example links for testing/demos
  def test; end

  private

  def redirect(message = nil)
    redirect_to new_local_requests_path(params: @local_request.to_h),
                flash: { error: message }
  end

  def set_request
    @local_request = LocalRequest.new @user, params
  end

  # @return [TrueClass, FalseClass]
  def mms_id_present?
    params.include? :mms_id
  end
end
