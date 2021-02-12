# override Alma gem's availability response to save bib data with availability data
# otherwise, we have to make an additional API call for bib data access
# also set total items from holding data so we can batch item requet calls
class Alma::AvailabilityResponse
  attr_reader :bib_data, :total_items

  def initialize(response)
    @availability = parse_bibs_data(response.each)
    @bib_data = response['bib'].first
    @total_items = @availability[@bib_data['mms_id']][:holdings]
                   .map { |h| h['total_items'].to_i }.reduce(0, :+)
  end
end
