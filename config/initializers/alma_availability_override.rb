# override Alma gem's availability response to save bib data with availability data
# otherwise, we have to make an additional API call for bib data access
class Alma::AvailabilityResponse
  def initialize(response)
    @availability = parse_bibs_data(response.each)
    @bib_data = response['bib'].first
  end

  # @return [Hash]
  def bib_data
    @bib_data
  end
end

# TODO: the right thing
class Alma::BibItem
  ETAS_TEMPORARY_LOCATION = 'TBD'
  PHYSICAL_ITEM_DELIVERY_OPTIONS = [:pickup, :booksbymail, :scandeliver]
  RESTRICTED_ITEM_DELIVERY_OPTIONS = [:scandeliver]
  
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

  def user_due_date
    item_data.dig 'due_date'
  end

  def user_due_date_policy
    item_data.dig 'due_date_policy'
  end

  def not_loanable?
    user_due_date_policy&.include? 'Not loanable'
  end

  # @return [Array]
  def delivery_options
    if checkoutable?
      PHYSICAL_ITEM_DELIVERY_OPTIONS
    else
      RESTRICTED_ITEM_DELIVERY_OPTIONS
    end
  end
  
  # @return [TrueClass, FalseClass]
  def etas_restricted?
    # is in ETAS temporary location?
    temp_location_name == ETAS_TEMPORARY_LOCATION
  end

  def label_for_radio_button
    label_info = [
      location_name,
      description,
      user_due_date_policy
    ]
    label_info.reject(&:blank?).join(' - ')
  end

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