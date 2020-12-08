class LocalRequestsController < ApplicationController
  helper LocalRequestsHelpers

  before_action :redirect, unless: :mms_id_present?
  before_action :set_user
  before_action :set_metadata

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

  # @return [AlmaUser]
  def set_user
    @user = AlmaUser.new helpers.username_from_headers
  end

  def set_metadata
    availability_response = Alma::Bib.get_availability(Array.wrap(params[:mms_id]))
    holdings_metadata = availability_response.availability[params[:mms_id]][:holdings]
    @bib_data = availability_response.bib_data
    if holdings_metadata.one?
      @items = set_items holdings_metadata.first['holding_id']
    else
      @holdings = holdings_from holdings_metadata
      # TODO: what if there arent too many items? we could prefetch...
      available_items = @holdings.map(&:available_items).reduce(0, :+)
      if (@holdings.length < 5 && available_items < 15) || available_items == @holdings.length
        item_sets = @holdings.map do |holding|
          lookup_items holding.id, params[:mms_id].to_s, @user
        end
        @items = item_sets.map(&:items).flatten
      end
    end
  end

  # @param [String] holding_id
  def set_items(holding_id)
    items = lookup_items holding_id, params[:mms_id].to_s, @user
    @item = items.first if items.one?
    items
  end

  # @param [Array] holdings_metadata
  # @return [Array<AlmaHolding>]
  def holdings_from(holdings_metadata)
    holdings_metadata.map do |holding_metadata|
      AlmaHolding.new holding_metadata
    end
  end

  # @return [Alma::BibItemSet]
  # @param [String] holding_id
  # @param [String] mms_id
  # @param [AlmaUser] user
  def lookup_items(holding_id, mms_id, user)
    Alma::BibItem.find mms_id, holding_id: holding_id, expand: 'due_date,due_date_policy', user_id: user.id
  end

  # @return [TrueClass, FalseClass]
  def mms_id_present?
    param_present? :mms_id
  end

  # @param [Symbol, String] param
  # @return [TrueClass, FalseClass]
  def param_present?(param)
    params.key? param
  end
end
