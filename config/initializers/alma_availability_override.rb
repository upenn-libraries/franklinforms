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
  def eligible_for_use?
    in_place? && !non_circulating? && !etas_restricted?
  end
  
  # @return [Array]
  def delivery_options
    if eligible_for_use?
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
end