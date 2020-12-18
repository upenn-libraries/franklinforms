module LocalRequestsHelper
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

  # @param [AlmaRecord] record
  def placeholder_for_delivery_select(record)
    if record.one_item?
      t('forms.local_request.messages.select_delivery_option')
    else
      t('forms.local_request.messages.select_an_item')
    end
  end
end
