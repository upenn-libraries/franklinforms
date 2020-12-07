# override Alma gem's availability response to save bib data with availability data
# otherwise, we have to make an additional API call for bib data access
class Alma::AvailabilityResponse
  def initialize(response)
    super(response)
    @bib_data = response['bib'].first
  end

  # @return [Hash]
  def bib_data
    @bib_data
  end
end