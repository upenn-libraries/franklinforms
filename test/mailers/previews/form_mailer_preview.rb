# Preview all emails at http://localhost:3000/rails/mailers/form_mailer
class FormMailerPreview < ActionMailer::Preview

  def confirm_enhanced_email
    FormMailer.confirm_enhanced_email
  end

  def confirm_missing_email
    FormMailer.confirm_missing_email
  end

  def confirm_fixopac_email
    FormMailer.confirm_fixopac_email
  end
  
  def send_enhanced_email
    FormMailer.send_enhanced_email
  end

  def send_missing_email
    FormMailer.send_missing_email
  end

  def send_fixopac_email
    FormMailer.send_fixopac_email
  end
end
