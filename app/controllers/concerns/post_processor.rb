module PostProcessor

  def post_process(form_id, vars)
    #return if Rails.env.development? && form_id != 'ill'

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
        illiad_service = Illiad.new
        if user.data['illiadrecord'] == 'new'
          illiad_service.addIlliadUser(user)
        elsif user.data['illiadrecord'] == 'modify'
          illiad_service.updateIlliadUser(user)
        end
        txnumber = illiad_service.submit(user, bib, values)
        FormMailer.confirm_illiad_email(user, bib, txnumber, values).deliver_now
      when 'booksbymail'
        FormMailer.confirm_booksbymail_email(user, bib, values).deliver_now
      when 'help'
        FormMailer.send_help_email(values).deliver_now
      else
        # TODO probably should email an admin here
        #raise 
    end
  end

end
