class LocalRequestsController < ApplicationController
  include AlmaUserLookup

  before_action :redirect, unless: :mms_id_present?
  before_action :set_user
  before_action :set_record, only: :new

  # show the form
  def new
    @local_request = LocalRequest.new @user
  end

  # submit the request
  def create
    @local_request = LocalRequest.new @user, params
    # get item for validating request
    @item = Alma::BibItem.find(
      @local_request.mms_id,
      holding_id: @local_request.holding_id
    ).reject do |item| # ugly
      item.pid != @local_request.item_pid
    end.first
    # @local_request.submit
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
