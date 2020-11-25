module LocalRequestsHelpers
  # @param [String] request_type
  # @param [FormBuilder] form_builder
  def show_request_type_fields(request_type, form_builder)
    partial =  case request_type
               when :book, :scan, :article
                 request_type.to_s
               else
                 raise ArgumentError, 'Unsupported request type'
               end
    render partial: partial, locals: { f: form_builder }
  end
end