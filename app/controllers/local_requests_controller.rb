class LocalRequestsController < ApplicationController
  include AlmaUserLookup

  before_action :redirect, unless: :mms_id_present?
  before_action :set_user
  before_action :set_record, except: :test

  # show the form
  def new
    @local_request = LocalRequest.new params, @user
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

  def redirect
    # TODO: show error page if no mms_id param found
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
