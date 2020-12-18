module LocalRequestsHelper
  # @param [AlmaRecord] record
  def delivery_options_for_select(record)
    if record.one_item?
      Alma::BibItem::PHYSICAL_ITEM_DELIVERY_OPTIONS
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
