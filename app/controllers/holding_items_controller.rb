class HoldingItemsController < ApplicationController
  include AlmaUserLookup

  before_action :set_user

  # return JSON for items for a given holding
  # params mms_id, holding_id
  def index
    items = AlmaRecord.new(
      params[:mms_id].to_s,
      holding_id: params[:holding_id],
      user_id: @user.id
    ).items.map(&:for_radio_button)

    render json: items
  end
end