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
        if params[:use_api]
          Illiad.add_illiad_user_api user
        else
          Illiad.addIlliadUser(user)
        end
      elsif user.data['illiadrecord'] == 'modify'
        Illiad.updateIlliadUser(user)
      end
      txnumber = if params[:use_api]
                   response = Illiad.api_submit user, bib, values
                   response[:confirmation_number]
                 else
                   Illiad.submit(user, bib, values)
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
