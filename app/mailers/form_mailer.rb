class FormMailer < ApplicationMailer
  default from: ENV['DEVELOPMENT_EMAIL']

  def send_enhanced_email(user, bib, values)
    @to = 'fixopac@pobox.upenn.edu'
    @subject = 'Request enhanced cataloging'
    send_email(user, bib, values)
  end

  def send_missing_email(user, bib, values)
    @to = FormMailer.get_location_email(values[:location])
    @subject = 'Report missing item'
    send_email(user, bib, values)
  end

  def send_fixopac_email(user, bib, values)
    @to = 'fixopac@pobox.upenn.edu'
    @subject = 'Fix OPAC request'
    send_email(user, bib, values)
  end

  def send_email(user, bib, values)
    @from = user.data['email']
    @name = user.name
    @pennid = user.data['penn_id']
    @title = bib.title
    @bibid = bib.bibid
    @mfhdid = values[:mfhdid]
    @author = bib.author
    @callno = bib.call_number
    @iteminfo = values[:iteminfo]
    @comments = values[:comments]

    if Rails.env.development?
      @subject = "TEST " + @subject + " (to: #{@to}, from: #{@from})"
      @to = ENV['DEVELOPMENT_EMAIL']
      @from = ENV['DEVELOPMENT_EMAIL']
    end

    mail(to: @to,
         from: @from,
         subject: @subject,
         template_name: 'send_email')
  end

  def confirm_enhanced_email(user, bib, values)
    @from = "fixopac@pobox.upenn.edu"
    @subject = "Request Enhanced Cataloging"
    confirm_email(user, bib, values)
  end

  def confirm_missing_email(user, bib, values)
    @from = FormMailer.get_location_email(values[:location])
    @subject = "Report a Missing Item"
    confirm_email(user, bib, values)
  end

  def confirm_fixopac_email(user, bib, values)
    @from = "fixopac@pobox.upenn.edu"
    @subject = "Report a Problem with this Record"
    confirm_email(user, bib, values)
  end

  def confirm_email(user, bib, values)
    @to = user.data['email']
    @title = bib.title
    @author = bib.author

    if Rails.env.development?
      @subject = "TEST " + @subject + " (to: #{@to}, from: #{@from})"
      @to = ENV['DEVELOPMENT_EMAIL']
      @from = ENV['DEVELOPMENT_EMAIL']
    end

    mail(to: @to,
         from: @from,
         subject: @subject,
         template_name: 'confirm_email')
  end

  def self.get_location_email(location)
    case location
      when /afro/i then "vpstacks@pobox.upenn.edu" 
      when /^annb/i then "sblack@asc.upenn.edu" 
      when /^biom/i then "circbio@pobox.upenn.edu" 
      when /^chem/i then "chemlib@pobox.upenn.edu" 
      when /^cjs/i then "cajs@pobox.upenn.edu"      
      when /classics/i then "vpstacks@pobox.upenn.edu" 
      when /dent/i then "bjenkins@pobox.upenn.edu"  
      when /easia/i then "vpstacks@pobox.upenn.edu" 
      when /easiasem/i then "vpstacks@pobox.upenn.edu" 
      when /engi/i then "townelib@seas.upenn.edu" 
      when /^fine/i then "finearts@pobox.upenn.edu" 
      when /judaica/i then "vpstacks@pobox.upenn.edu" 
      when /lipp/i then "lippinco@wharton.upenn.edu" 
      when /math/i then "mpalib@pobox.upenn.edu" 
      when /medieval/i then "vpstacks@pobox.upenn.edu" 
      when /mideast/i then "vpstacks@pobox.upenn.edu" 
      when /^muse/i then "jasonfd@pobox.upenn.edu" 
      when /musiclist/i then "griscom@pobox.upenn.edu" 
      when /musicsem/i then "vpstacks@pobox.upenn.edu" 
      when /newb/i then "vetlib@pobox.upenn.edu"            
      when /sasiarefe/i then "vpstacks@pobox.upenn.edu"          
      when /scfurn/i then "scmissing@lists.upenn.edu"         
      when /sclea/i then "scmissing@lists.upenn.edu" 
      when /scrare/i then "scmissing@lists.upenn.edu" 
      when /screfe/i then "scmissing@lists.upenn.edu" 
      when /scsmith/i then "scmissing@lists.upenn.edu" 
      when /^vanp$/i then "vpstacks@pobox.upenn.edu" 
      when /vanpinfo/i then "vpstacks@pobox.upenn.edu" 
      when /vanpmicro/i then "vpstacks@pobox.upenn.edu"          
      when /vanpvideo/i then "vpstacks@pobox.upenn.edu" 
      when /vete/i then "vetlib@pobox.upenn.edu" 
      when /^vpref$/i then "vpstacks@pobox.upenn.edu" 
      when /vprefmoel/i then "vpstacks@pobox.upenn.edu"          
      when /vpwicref/i then "vpstacks@pobox.upenn.edu" 
      when /yarn/i then "vpstacks@pobox.upenn.edu"    
    end
  end
end
