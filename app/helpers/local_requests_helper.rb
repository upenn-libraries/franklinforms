module LocalRequestsHelper
  # Return delivery option information in array format for use
  # in form select helper
  # @param [AlmaRecord] record
  def delivery_options_for_select(record)
    if record.items.one?
      record.items.first.delivery_options
        .map do |option|
        [I18n.t("forms.local_request.types.#{option}"), option]
      end
    else
      # JS will handle
      []
    end
  end

  def new_delivery_options_for_select(record)
    options_for_select delivery_options_for_select record
  end

  # Return placeholder for delivery options select
  # @param [AlmaRecord] record
  def placeholder_for_delivery_select(record)
    if record.items.one?
      t('forms.local_request.messages.select_delivery_option')
    else
      t('forms.local_request.messages.select_an_item')
    end
  end

  # is the record only eligible for digital delivery?
  # used when rendering delivery options form elements
  # server-side
  # @param [AlmaRecord] record
  # @param [LocalRequest] request
  def show_digital_delivey_fields?(record, request)
    return true if request.scandeliver_request?

    # if there's more that one item, it's too hard to decide
    return false unless record.one_item?

    # if the item is checkoutable, then it's eligible for
    # circulation options
    true unless record.items.first.checkoutable?
  end

  # Link to Franklin search for a title string with the Online facet set
  # @param [String] title
  # @return [ActiveSupport::SafeBuffer]
  def franklin_online_search_link(title)
    title_escaped = CGI.escape title
    link_to 'Search Franklin for Online availability',
            "https://franklin.library.upenn.edu/catalog?utf8=%E2%9C%93&f%5Baccess_f%5D%5B%5D=Online&op=AND&sort=score+desc&search_field=keyword&q=#{title_escaped}"
  end

  def test_link_element(label, mms_id, additional_params = {})
    params = { mms_id: mms_id }.merge! additional_params
    link_to(label, new_local_requests_path(params)) + ' / ' +
      link_to(
        'Franklin Record',
        "https://franklin.library.upenn.edu/catalog/FRANKLIN_#{mms_id}"
      )
  end
end
