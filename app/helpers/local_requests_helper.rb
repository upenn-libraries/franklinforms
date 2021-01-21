module LocalRequestsHelper
  # Return delivery option information in array format for use
  # in form select helper
  # @param [AlmaRecord] record
  def delivery_options_for_select(record)
    if record.one_item?
      record.items.first.delivery_options
        .map do |option|
        [I18n.t("forms.local_request.types.#{option}"), option]
      end
    else
      # JS will handle
      []
    end
  end

  # Return placeholder for delivery options select
  # @param [AlmaRecord] record
  def placeholder_for_delivery_select(record)
    if record.one_item?
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
end
