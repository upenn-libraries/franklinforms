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

  def send_help_email(values)
    @to = 'library@pobox.upenn.edu'
    @from = values['email']
    @subject = 'Summon Help Requested'

    @name = values['name']
    @referrer = values[:referrer]
    @details = values[:details]

    if Rails.env.development?
      @subject = "TEST " + @subject + " (to: #{@to}, from: #{@from})"
      @to = ENV['DEVELOPMENT_EMAIL']
      @from = ENV['DEVELOPMENT_EMAIL']
    end

    mail(to: @to,
         from: @from,
         subject: @subject,
         template_name: 'send_help_email')
  end

  def send_email(user, bib, values)
    @from = user.data['email']
    @name = user.name
    @pennid = user.data['penn_id']
    @title = values[:title]
    @bibid = values[:bibid]
    @mfhdid = values[:mfhdid]
    @author = values[:author]
    @callno = values[:call_number]
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
    @reqtype = "Request Enhanced Cataloging"
    confirm_email(user, bib, values)
  end

  def confirm_missing_email(user, bib, values)
    @from = FormMailer.get_location_email(values[:location])
    @subject = "Report a Missing Item"
    @reqtype = "Report a Missing Item"
    confirm_email(user, bib, values)
  end

  def confirm_fixopac_email(user, bib, values)
    @from = "fixopac@pobox.upenn.edu"
    @subject = "Report a Problem with this Record"
    @reqtype = "Report a Problem with this Record"
    confirm_email(user, bib, values)
  end

  def confirm_illiad_email(user, bib, txnumber, values)
    userinfo = user.data

    @to = userinfo['emailAddr']
    @from = ''
    @subject = 'Request Confirmation'

    @name = "#{userinfo['first_name']} #{userinfo['last_name']}"
    @author = bib['author']
    @transactionnumber = txnumber

    if(userinfo['status']) == 'StandingFaculty'
      @from = 'pld@pobox.upenn.edu'
      @reqtype = 'FacultyEXPRESS'
      @addldeliveryinfo = ''

    else
      @from = case userinfo['illoffice']
      when 'BIOMED'
        'bioill@pobox.upenn.edu'
      when 'DENTAL'
        'dentlib@pobox.upenn.edu'
      when 'VET'
        'vetlib@pobox.upenn.edu'
      else
        'interlib@pobox.upenn.edu'
      end

      @reqtype = 'Interlibrary Loan'
      @addldeliveryinfo = 'Delivery times vary depending upon lender location.  You will receive an email as soon as your request is available.'

    end

    if(bib['requesttype'].downcase == 'book')
      @title = bib['booktitle']
      @publisher = bib['publisher']
      @place = bib['place']
      @date = bib['rftdate'] || bib['year']
      @edition = bib['edition']
      template_name = 'confirmillbook'
    elsif(bib['requesttype'] == 'ScanDelivery')
      @title = bib['title']
      @chaptitle = bib['chaptitle']
      @volume = bib['volume']
      @issue = bib['issue']
      @pages = bib['pages']
      #@year = bib['year'] || bib['rftdate']
      @citationsource = bib['sid']
      @isbn = bib['isbn']
      template_name = 'confirmillscan'
    else
      @title = bib['journal']
      @volume = bib['volume']
      @issue = bib['issue']
      @pages = bib['pages']
      @year = bib['year'] || bib['rftdate']
      @articletitle = bib['article']
      template_name = 'confirmilljournal'
    end

    if Rails.env.development?
      @subject = "TEST " + @subject + " (to: #{@to}, from: #{@from})"
      @to = ENV['DEVELOPMENT_EMAIL']
      @from = ENV['DEVELOPMENT_EMAIL']
    end

    mail(to: @to,
         from: @from,
         subject: @subject,
         template_name: template_name)
  end

  def confirm_booksbymail_email(user, bib, values)
    @to = "bkbymail@pobox.upenn.edu"
    @from = "#{user.name} <#{user.data['email']}>"
    @subject = "Books by Mail Request"

    @title = values['title']
    @bibid = values['bibid']
    @author = values['author']
    @publication = values['publication']
    @callno = values['call_no']
    @volume = values['volume']
    @comments = values[:comments]
    @patronname = user.name 
    @patronemail = values['email']
    @pennid = user.data['penn_id']

    if Rails.env.development?
      @subject = "TEST " + @subject + " (to: #{@to}, from: #{@from})"
      @to = ENV['DEVELOPMENT_EMAIL']
      @from = ENV['DEVELOPMENT_EMAIL']
    end

    mail(to: @to,
         from: @from,
         subject: @subject,
         template_name: 'confirm_booksbymail')
  end

  def confirm_email(user, bib, values)
    @to = user.data['email']
    @title = values[:title]
    @author = values[:author]
    @comments = values[:comments]

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
