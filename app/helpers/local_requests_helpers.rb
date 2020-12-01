module LocalRequestsHelpers
  # @param [String] request_type
  def request_type_message(request_type)
    case request_type
    when :article
      t('forms.local_request.types.article')
    when :book
      t('forms.local_request.types.book')
    when :scan
      t('forms.local_request.types.scan')
    end
  end

  # @param [String] request_type
  # @param [FormBuilder] form_builder
  def request_type_fields(request_type, form_builder)
    render partial: request_type.to_s, locals: { f: form_builder }
  end
end