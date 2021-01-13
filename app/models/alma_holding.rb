class AlmaHolding < OpenStruct
  def initialize(hash = nil)
    super hash
  end

  # @return [String]
  def id
    self.holding_id
  end

  # @return [String]
  def label
    "#{library} -  #{location} - #{holding_info}"
  end

  # @return [TrueClass, FalseClass]
  def available?
    self.availability == 'available' ||
      self.availability == 'check_holdings'
  end

  # @return [Integer]
  def available_items
    total_items = self.total_items.to_i
    unavailable_items = self.non_available_items.to_i
    total_items - unavailable_items
  end
end