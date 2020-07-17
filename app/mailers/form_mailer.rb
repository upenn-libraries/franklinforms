class FormMailer < ApplicationMailer
  default from: ENV['DEVELOPMENT_EMAIL']

  def send_enhanced_email(user, bib, values)
    @to = 'fixopac@pobox.upenn.edu'

    report_type = values[:report_type]
    case report_type
      when 'missing'
        send_missing_email(user, bib, values)
      when 'fixopac'
        send_fixopac_email(user, bib, values)
      else
        @subject = 'Request enhanced cataloging'
        send_email(user, bib, values)
    end
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
    @mfhdid = values[:holding]
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

    report_type = values[:report_type]
    case report_type
      when 'missing'
        confirm_missing_email(user, bib, values)
      when 'fixopac'
        confirm_fixopac_email(user, bib, values)
      else
        @subject = "Request Enhanced Cataloging"
        @reqtype = "Request Enhanced Cataloging"
        confirm_email(user, bib, values)
    end
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

    # use email from form if userinfo doesn't have an address
    @to = userinfo['emailAddr'] || values['email']
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
      when "afro" then "vpstacks@pobox.upenn.edu"
      when "annbcirc" then "sblack@asc.upenn.edu"
      when "annbrefe" then "sblack@asc.upenn.edu"
      when "annbrese" then "sblack@asc.upenn.edu"
      when "arbor" then "vpstacks@pobox.upenn.edu"
      when "biom" then "libref@mail.med.upenn.edu"
      when "chem" then "chemlib@pobox.upenn.edu"
      when "cjs" then "cajs@pobox.upenn.edu"
      when "classics" then "vpstacks@pobox.upenn.edu"
      when "dent" then "baumans@upenn.edu"
      when "easiasem" then "vpstacks@pobox.upenn.edu"
      when "eastasia" then "vpstacks@pobox.upenn.edu"
      when "fine" then "finearts@pobox.upenn.edu"
      when "judaica" then "vpstacks@pobox.upenn.edu"
      when "lipp" then "lippinco@wharton.upenn.edu"
      when "math" then "mpalib@pobox.upenn.edu"
      when "medieval" then "vpstacks@pobox.upenn.edu"
      when "mideast" then "vpstacks@pobox.upenn.edu"
      when "muse" then "jasonfd@pobox.upenn.edu"
      when "musiclist" then "lizavick@upenn.edu"
      when "musicsem" then "vpstacks@pobox.upenn.edu"
      when "newb" then "vetlib@pobox.upenn.edu"
      when "rotc" then "scmissing@lists.upenn.edu"
      when "sasiarefe" then "vpstacks@pobox.upenn.edu"
      when "scfurn" then "scmissing@lists.upenn.edu"
      when "sclea" then "scmissing@lists.upenn.edu"
      when "scrare" then "scmissing@lists.upenn.edu"
      when "screfe" then "scmissing@lists.upenn.edu"
      when "scsmith" then "storage@pobox.upenn.edu"
      when "stor" then "vetlib@pobox.upenn.edu"
      when "vanpinfo" then "vpstacks@pobox.upenn.edu"
      when "vanpmicro" then "vpstacks@pobox.upenn.edu"
      when "vanp" then "vpstacks@pobox.upenn.edu"
      when "vanpvideo" then "vpstacks@pobox.upenn.edu"
      when "vete" then "vpstacks@pobox.upenn.edu"
      when "vprefmoel" then "vpstacks@pobox.upenn.edu"
      when "vpref" then "vpstacks@pobox.upenn.edu"
      when "vpwicref" then "vpstacks@pobox.upenn.edu"
      when "yarn" then "vpstacks@pobox.upenn.edu"
      else "vpstacks@pobox.upenn.edu"
    end
  end
end
