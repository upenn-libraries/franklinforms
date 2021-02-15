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

  def confirm
    @item = AlmaApiClient.new.find_item_for(
      mms_id: params[:mms_id], holding_id: params[:holding_id], item_pid: params[:item_pid]
    ) # TODO: rescue
    if validate_request_for @item, params
      render :confirm, layout: false
    else
      render :problem, layout: false
    end
  end

  # submit the request
  def create; end

  # show confirmation
  def show; end

  # example links for testing/demos
  def test; end

  private

  # @param [Alma::BibItem] item
  def validate_request_for(item, params)
    item.delivery_options.include? params[:delivery].to_sym
  end

  # @return [TrueClass, FalseClass]
  def mms_id_present?
    params.include? :mms_id
  end
end
