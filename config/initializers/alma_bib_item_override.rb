# TODO: push these up to the Alma gem? Some of these are Penn-specific, others are not
class Alma::BibItem
  ETAS_TEMPORARY_LOCATION = 'Van Pelt - Non Circulating'.freeze
  PHYSICAL_ITEM_DELIVERY_OPTIONS = %i[pickup booksbymail scandeliver].freeze
  RESTRICTED_ITEM_DELIVERY_OPTIONS = [:scandeliver].freeze

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

  # Label text for Item radio button
  # @return [String]
  def label_for_select
    label_info = [
      physical_material_type['desc'],
      enumeration,
      chronology,
      public_note,
      user_policy_display(user_due_date_policy),
      location_name
    ]
    label_info.reject(&:blank?).join(' - ')
  end

  def enumeration
    enum_a = item_data['enumeration_a']
    enum_b = item_data['enumeration_b']
    "#{enum_a} #{enum_b}".strip.gsub('v.', 'Volume ').gsub('no.', 'Number ').gsub('pt.', 'Part ')
  end

  def chronology
    chron_a = item_data['chronology_i']
    chron_b = item_data['chronology_j']
    chron_c = item_data['chronology_k']
    "#{chron_a} #{chron_b} #{chron_c}".strip
  end

  def improved_description
    og_description = description
    gsubd_desc = og_description.gsub('v.', 'Volume ').gsub('no.', 'Number ').gsub('pt.', 'Part ')
    issue = item_data['enumeration_a']&.gsub('v.', '')
    volume = item_data['enumeration_b']&.gsub('no.', '')
    year = item_data['chronology_i']
    month = item_data['chronology_j'] || 1
    day = item_data['chronology_k'] || 1

    "#{physical_material_type['desc']} #{issue} - Volume #{volume}. #{month} #{year}"
  end

  # @param [String] raw_policy
  def user_policy_display(raw_policy)
    case raw_policy
    when 'Not loanable'
      'Digital Delivery Only'
    when 'End of Year'
      'Return by End of Year'
    when 'End of Term'
      'Return by End of Term'
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
