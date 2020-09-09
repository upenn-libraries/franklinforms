module FormHelper
  def render_bib_info_partial(form, record)
    locals = { f: form, record: record }
    partial = case record['requesttype']
              when 'Book'
                'form/ill_new/book'
              when 'ScanDelivery'
                'form/ill_new/scan'
              else
                'form/ill_new/article'
              end
    render partial: partial, locals: locals
  end

  def ill_form_type(params = params)
    'ILL Request'
  end

  def ill_request_type(user)
    if user.standing_faculty?
      'FacultyExpress'
    else
      'InterLibrary Loan'
    end
  end
end
