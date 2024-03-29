module PostProcessor

  def post_process(form_id, vars)

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
    when 'resourcesharing'
    when 'ill'
      if user.data['illiadrecord'] == 'new'
        Illiad.addIlliadUser(user)
      elsif user.data['illiadrecord'] == 'modify'
        Illiad.updateIlliadUser(user)
      end
      txnumber = Illiad.submit(user, bib, values)
      if txnumber.blank?
        Honeybadger.notify("No txnumber for request from user: #{user.data['emailAddr']} with values #{values}")
        redirect_to ill_problem_path
        return
      end
      FormMailer.confirm_illiad_email(user, bib, txnumber, values).deliver_now
    when 'booksbymail'
      FormMailer.confirm_booksbymail_email(user, bib, values).deliver_now
    when 'help'
      FormMailer.send_help_email(values).deliver_now
    else
      Honeybadger.notify(
          "Postprocessor received an unhandled form value: #{form_id}"
      )
    end
  end

end
