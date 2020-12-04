class LocalRequestsController < ApplicationController
  helper LocalRequestsHelpers

  before_action :set_user
  before_action :set_holdings, if: :mms_id_present?
  before_action :set_items, if: :holding_id_present?
  before_action :set_item, if: :item_id_present?

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

  def set_holdings
    availability_response = Alma::Bib.get_availability(Array.wrap(params[:mms_id]))
    @holdings = availability_response.availability[params[:mms_id]][:holdings]
  end

  def set_items
    @items = Alma::BibItem.find params[:mms_id],
                                holding_id: params[:holding_id],
                                user_id: @user.id
  end

  def set_item
    @item = @items.find do |item|
      item.item_data.dig('pid') == params[:item_pid]
    end
  end

  # @return [TrueClass, FalseClass]
  def mms_id_present?
    param_present? :mms_id
  end

  # @return [TrueClass, FalseClass]
  def holding_id_present?
    param_present? :holding_id
  end

  # @return [TrueClass, FalseClass]
  def item_id_present?
    param_present? :item_pid
  end

  # @param [Symbol, String] param
  # @return [TrueClass, FalseClass]
  def param_present?(param)
    params.key? param
  end
end
