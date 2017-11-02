class FranklinAvailability
  include HTTParty
  base_uri 'https://franklin.library.upenn.edu'

  def self.getAvailabilityNotes(mmsid)
    query = {:id_list => mmsid}

    availability = get("/alma/availability.json", :query => query). dig('availability', mmsid, 'holdings')

    if availability.present?
      return availability.reject { |hld| hld['link_to_aeon'] }
                         .map { |hld| "Location: #{hld['location']} #{hld['call_number']} #{hld['availability']}" }
                         .join("\n")
    else
      return ''
    end
  end

end
