class AlmaHolding < OpenStruct
  def initialize(hash = nil)
    super hash
  end

  def id
    self.holding_id
  end

  def radio_button_label
    "#{self.library} -  #{self.location} - #{self.available_items} #{'item'.pluralize(self.available_items)} available [#{self.id}]"
  end

  def available?
    self.availability == 'available'
  end

  def available_items
    total_items = self.total_items.to_i
    unavailable_items = self.non_available_items.to_i
    total_items - unavailable_items
  end
end