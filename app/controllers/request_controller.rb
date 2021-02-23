# frozen_string_literal: true

# Handle browser requests for a request
class RequestController < ApplicationController
  include AlmaUserLookup

  rescue_from TurboAlmaApi::Client::Timeout do |exception|
    redirect(exception.message)
  end

  # show the form
  def new
    @items = if params[:mms_id]
               TurboAlmaApi::Client.all_items_for(params[:mms_id].to_s,
                                                  @user.pennkey)
             else
               nil
             end

  end

  def confirm
    @item = TurboAlmaApi::Client.item_for(
      mms_id: params[:mms_id], holding_id: params[:holding_id], item_pid: params[:item_pid]
    ) # TODO: rescue
    if validate_request_for @item, params
      render :confirm, layout: false
    else
      render :problem, layout: false
    end
  end

  # submit the request
  def create
    request = LocalRequest.new @user, params
    if request.valid?
      submission = RequestSubmissionService.submit request
      if submission[:status] == :success
        render plain: "Submission Successful: #{submission[:message]}"
      else
        render plain: "Submission Failed: #{submission[:message]}"
      end
    else
      render plain: "Submission Invalid: #{pp request.errors}"
    end
  end

  # show confirmation
  def show; end

  # example links for testing/demos
  def test; end

  private

  # @param [PennItem] item
  def validate_request_for(item, params)
    item.delivery_options.include? params[:delivery_method].to_sym
  end

  # @return [TrueClass, FalseClass]
  def mms_id_present?
    params.include? :mms_id
  end
end
