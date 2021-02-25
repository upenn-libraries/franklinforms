class AlmaRecord
  attr_accessor :bib_data, :mms_id, :holding_id, :holdings, :items

  # Build AlmaRecord, grabbing availability data and setting
  # bib_data and holding info
  # Will pull item info if there isn't too much of it
  # @param [String] mms_id
  def initialize(mms_id, options = {})
    @mms_id = mms_id
    @holding_id = options[:holding_id]
    user_id  = options[:user_id] || 'GUEST'
    availability_response = Alma::Bib.get_availability(Array.wrap(mms_id))
    holdings_metadata = availability_response.availability[mms_id][:holdings]
    @bib_data = availability_response.bib_data
    @holdings = holdings_from holdings_metadata
    holding_ids = if @holding_id
                    Array.wrap @holding_id
                  else
                    @holdings.collect(&:id)
                  end
    @items = lookup_items_for(holding_ids, user_id) if should_prefetch_items?
  rescue Net::OpenTimeout => e
    raise TurboAlmaApi::Client::Timeout, "Problem with Alma API: #{e.message}"
  end

  # Is there only one Item?
  # @return [TrueClass, FalseClass]
  def one_item?
    items&.one?
  end

  private

  # Lookup Items in Alma for an array of holding_ids
  # TODO: Can't retrieve more than 100 without adding pagination
  # @param [Array<String>] holding_ids
  def lookup_items_for(holding_ids, user_id)
    items = holding_ids.map do |holding_id|
      TurboAlmaApi::Bib::PennItem.find(
        mms_id,
        holding_id: holding_id,
        user_id: user_id,
        expand: 'due_date,due_date_policy',
        limit: 100
      )
    end.map(&:items).flatten
    # ugly
    items.map { |bib_item| TurboAlmaApi::Bib::PennItem.new(bib_item.item) }
  rescue Net::OpenTimeout => e
    raise TurboAlmaApi::Client::Timeout, "Problem with Alma API: #{e.message}"
  end

  # Turn Alma's holdings data hash into AlmaHoldings
  # @param [Array] holdings_metadata
  # @return [Array<AlmaHolding>]
  def holdings_from(holdings_metadata)
    holdings_metadata.map do |holding_metadata|
      AlmaHolding.new holding_metadata
    end
  end

  # Check if items should be fetched
  # - there are only a few holdings
  # - there are not too many items in total
  # @return [TrueClass, FalseClass]
  def should_prefetch_items?
    return true if @holdings.one? || @holding_id

    available_items = @holdings.map(&:available_items).reduce(0, :+)
    few_holdings = @holdings.length < 5
    few_items = available_items < 15
    # one_item_per_holding = available_items == @holdings.length
    few_holdings && few_items
  end
end
