# TODO: push these up to the Alma gem? Some of these are Penn-specific, others are not
class Alma::BibItem
  ETAS_TEMPORARY_LOCATION = 'Van Pelt - Non Circulating'
  PHYSICAL_ITEM_DELIVERY_OPTIONS = [:pickup, :booksbymail, :scandeliver]
  RESTRICTED_ITEM_DELIVERY_OPTIONS = [:scandeliver]

  # @return [String]
  def pid
    item_data.dig 'pid'
  end

  # Determine, based on various response attributes, if this Item is
  # able to be circulated.
  # @return [TrueClass, FalseClass]
  def checkoutable?
    in_place? &&
      !non_circulating? &&
      !etas_restricted? &&
      !not_loanable?
  end

  # Penn uses "Non-circ" in Alma
  def non_circulating?
    circulation_policy.include?('Non-circ')
  end

  # @return [String]
  def user_due_date
    item_data.dig 'due_date'
  end

  # @return [String]
  def user_due_date_policy
    item_data.dig 'due_date_policy'
  end

  # @return [TrueClass, FalseClass]
  def not_loanable?
    user_due_date_policy&.include? 'Not loanable'
  end

  # Delivery options for this Item
  # @return [Array]
  def delivery_options
    if checkoutable?
      PHYSICAL_ITEM_DELIVERY_OPTIONS
    else
      RESTRICTED_ITEM_DELIVERY_OPTIONS
    end
  end

  # Is this Item restricted from circulation due to ETAS?
  # @return [TrueClass, FalseClass]
  def etas_restricted?
    # is in ETAS temporary location?
    temp_location_name == ETAS_TEMPORARY_LOCATION
  end

  # Label text for Item radio button
  # @return [String]
  def label_for_radio_button
    label_info = [
      location_name,
      description,
      user_policy_display(user_due_date_policy)
    ]
    label_info.reject(&:blank?).join(' - ')
  end

  # @param [String] raw_policy
  def user_policy_display(raw_policy)
    case raw_policy
    when 'Not loanable'
      'Digital Delivery Only'
    when 'End of Year'
      'Return by End of Year'
    else
      raw_policy
    end
  end

  # Hash of data used to build Item radio button client side
  # Used by HoldingItems API controller
  # @return [Hash]
  def for_radio_button
    {
      pid: item_data['pid'],
      label: label_for_radio_button,
      delivery_options: delivery_options,
      checkoutable: checkoutable?,
      etas_restricted: etas_restricted?,
    }
  end
end