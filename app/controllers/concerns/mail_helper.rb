module MailHelper

  def send_emails_for_form(form_id, vars)
    user = vars[:user]
    bib = vars[:record]
    values = vars[:params]

    case form_id
      when 'fixit'
        FormMailer.send_fixopac_email(user, bib, values).deliver_now
        FormMailer.confirm_fixopac_email(user, bib, values).deliver_now
      when 'missing'
        FormMailer.send_missing_email(user, bib, values).deliver_now
        FormMailer.confirm_missing_email(user, bib, values).deliver_now
      when 'enhanced'
        FormMailer.send_enhanced_email(user, bib, values).deliver_now
        FormMailer.confirm_enhanced_email(user, bib, values).deliver_now
      else
        # TODO probably should email an admin here
        raise 
    end
  end

end
