class Illiad

  @illoffices = Hash.new() { 'Van Pelt Library' }
  @illoffices['BIOMED'] = 'Biomedical Library'
  @illoffices['DENTAL'] = 'Dental Medicine Library'
  @illoffices['VET'] = 'Veterinary Medicine Library'

  def self.getBibData(params)
    bib_data = Hash.new
    aulast = params['rft.aulast'].presence || params['aulast'].presence || nil
 
    bib_data['author'] = nil
    bib_data['author'] = "#{aulast}#{params['rft.aufirst'].presence&.prepend(',')}" unless aulast.presence.nil?
    bib_data['author'] = params['Author'].presence || params['author'].presence || params['aau'].presence || params['au'].presence || params['rft.au'].presence || bib_data['author'].presence || ''

    # Use the book request form for unknown genre types
    if (params['genre'].presence || params['rft.genre'].presence || '').downcase == 'unknown' then
      bib_data['requesttype'] = 'Book'
    else
      bib_data['requesttype'] = params['genre'].presence || params['Type'].presence || params['requesttype'].presence || params['rft.genre'].presence || 'Article'
      bib_data['requesttype'] = 'Article' if bib_data['requesttype'] == 'issue'
      bib_data['requesttype'].sub!(/^(journal|bookitem|book|conference|article|preprint|proceeding).*?$/i, '\1')
      bib_data['requesttype'][0] = bib_data['requesttype'][0].upcase if ['article', 'book'].member?(bib_data['requesttype'])
    end
  
    bib_data['chaptitle'] = params['chaptitle'].presence;
    bib_data['booktitle'] = params['title'].presence     || params['Book'].presence        || params['bookTitle'].presence || params['booktitle'].presence || params['rft.title'].presence || '';
    bib_data['edition']   = params['edition'].presence   || params['rft.edition'].presence || '';
    bib_data['publisher'] = params['publisher'].presence || params['Publisher'].presence   || params['rft.pub'].presence   || '';
    bib_data['place']     = params['place'].presence     || params['PubliPlace'].presence  || params['rft.place'].presence || '';
    bib_data['an']        = params['AN'].presence        || '';
    bib_data['py']        = params['PY'].presence        || '';
    bib_data['pb']        = params['PB'].presence        || '';
    bib_data['journal']   = params['Journal'].presence   || params['journal'].presence     || params['rft.btitle'].presence || params['rft.jtitle'].presence || params['rft.title'].presence || params['title'].presence || '';
    bib_data['article']   = params['Article'].presence   || params['article'].presence     || params['atitle'].presence     || params['rft.atitle'].presence || '';
    bib_data['pmonth']    = params['pmonth'].presence    || params['rft.month'].presence   ||'';
    bib_data['rftdate']   = params['rftdate'].presence   || params['rft.date'].presence;
    bib_data['year']      = params['Year'].presence      || params['year'].presence || params['rft.year'] || params['rft.pubyear'].presence || params['rft.pubdate'].presence;
    bib_data['volume']    = params['Volume'].presence    || params['volume'].presence      || params['rft.volume'].presence || '';
    bib_data['issue']     = params['Issue'].presence     || params['issue'].presence       || params['rft.issue'].presence  || '';
    bib_data['issn']      = params['issn'].presence      || params['ISSN'].presence        || params['rft.issn'].presence   ||'';
    bib_data['isbn']      = params['isbn'].presence      || params['ISBN'].presence        || params['rft.isbn'].presence   || '';
    bib_data['sid']       = params['sid'].presence       || params['rfr_id'].presence      || '';
    bib_data['pid']       = params['pid'].presence       || '';
    bib_data['source']    = params['source'].presence    || "direct";
    bib_data['comments']  = params['UserId'].presence    || params['comments'].presence    || '';
    bib_data['bibid']     = params['record_id'].presence || params['id'].presence          || params['bibid'].presence      || '';

    # Handles IDs coming like pmid:numbersgohere
    unless params['rft_id'].presence.nil?
      parts = params['rft_id'].split(':')
      bib_data[parts[0]] = parts[1]
    end
  
    # *** Relais/BD sends dates through as rft.date but it may be a book request ***
    if(bib_data['sid'] == 'BD' && bib_data['requesttype'] == 'Book')
      bib_data['year'] = params['date'].presence || bib_data['rftdate']
    end
  
    ## Lookup record in Alma on submit?
  
    # *** Make the bookitem booktitle the journal title ***
    bib_data['journal'] = params['bookTitle'].presence || bib_data['journal'] if bib_data['requesttype'] == 'bookitem';
  
    # *** scan delivery uses journal title || book title, which ever we have ***
    # *** we should only have one of them ***
    bib_data['title'] = bib_data['booktitle'].presence || bib_data['journal'].presence;

    # *** Make a non-inclusive page parameter ***
    bib_data['spage'] = params['Spage'].presence || params['spage'].presence || params['rft.spage'].presence || "";
    bib_data['epage'] = params['Epage'].presence || params['epage'].presence || params['rft.epage'].presence || "";

    if(!params['Pages'].presence.nil? && bib_data['spage'].empty?)
      bib_data['spage'], bib_data['epage'] = params['Pages'].split(/-/);
    end

    if(params['pages'].presence.nil?)
      bib_data['pages'] = bib_data['spage'];
      bib_data['pages'] += "-#{bib_data['epage']}" unless bib_data['epage'].empty?
    else
      bib_data['pages'] = params['pages'].presence
    end

    bib_data['pages'] = 'none specified' if bib_data['pages'].empty?
  
    return bib_data
  
  end

  def self.getIlliadUserInfo(user, params)

    db = TinyTds::Client.new(username: ENV['ILLIAD_USERNAME'], password: ENV['ILLIAD_PASSWORD'], host: ENV['ILLIAD_DBHOST'], database: ENV['ILLIAD_DATABASE'])

    tablename = ENV['ILLIAD_ENV'] == 'production' ? 'usersall' : 'users'

    userinfo = user.data

    query = %Q{SELECT emailaddress,phone,department,nvtgc,address,address2,status,cleared
               FROM #{tablename}
               WHERE username = '#{db.escape(userinfo['proxied_for'] || '')}'
    }

    result = db.execute(query).entries.first || Hash.new

    userinfo['emailAddr'] = params['email'].presence || result['emailaddress'] || userinfo['email'] || ''
    # CHECK FOR INVALID EMAIL ADDRESS

    userinfo['phone'] = result['phone'] || ''
    userinfo['cleared'] = result['cleared'] || ''
    userinfo['delivery'] = ''

    if result['status'].nil?
      userinfo['illiadrecord'] = 'new'
      userinfo['illoffice'] = getILLOffice(userinfo)
      #userinfo['delivery'] = getDeliveryAddr(userinfo) || ''
    elsif userinfo['dept'] != result['department'] ||
          userinfo['illoffice'] != result['nvtgc'] ||
          userinfo['status'] != result['status'] ||
          userinfo['emailAddr'] != result['emailaddress'] ||
          userinfo['phone'] != result['phone']
      userinfo['illiadrecord'] = 'modify'
      userinfo['dept'] = result['department']
      userinfo['illoffice'] = result['nvtgc'] || getILLOffice(userinfo)
      userinfo['delivery'] = result['address'] || userinfo['delivery']
      userinfo['status'] = result['status'] || userinfo['status']
    else
      userinfo['illiadrecord'] = 'nochange'
    end

    userinfo['illoffice_name'] = @illoffices[userinfo['illoffice']]

    db.close

    return userinfo
  end

  def self.getCorrectedDeptDetails(userinfo)
    if userinfo['status'] != 'StandingFaculty'
      return nil
    end

    active_i = userinfo['org_active_code'].each_with_index.select {|v,i| v != 'I'} .map {|v| v[1]}
    corrected = active_i.map {|v| DeptMapping[userinfo['org_code'][v]]} .compact.first
    unless(corrected.nil?)
      userinfo['dept'] = corrected[:dept]
      userinfo['mailing_addr'] = corrected[:address]
    end
  end

  def self.getILLOffice(userinfo)
    office = nil
    active_i = userinfo['org_active_code'].each_with_index.select {|v,i| v != 'I'} .map {|v| v[1]}
    active_i.each do |i|
      org_code = userinfo['org_code'][i]
      if(['5021','VEM','VET','VTP'].member?(org_code) ||
         !(org_code =~ /58\d\d/).nil? ||
         userinfo['emailAddr'].end_with?("@vet.upenn.edu"))

         office ||= 'VET'
      elsif(['5020','DEN','DPH'].member?(org_code) ||
            !(org_code =~ /51\d\d/).nil? ||
            userinfo['emailAddr'].end_with?("@dental.upenn.edu") ||
            userinfo['emailAddr'].end_with?("@biochem.dental.upenn.edu"))

        office ||= 'DENTAL'
      elsif(['BFC','CCA','CCNJ','CNTRT','CORP',
             'CPUP','CPUPH','GAMBR','HUP','JRB',
             'MDPAH','MDPMC','MDUPM','MGMT','MHUP',
             'MPAH','MPMC','PAH','PAHHM','PERFS',
             'PMC','SCON','TPHX','TPHXD','URSVC',
             '5019','BMP','MDP','MED','NRP',
             'NUG','NUR','NUP','PDM','CHOP'].member?(org_code) ||
             !(org_code =~ /4\d\d\d/).nil? ||
             userinfo['emailAddr'].ends_with?("mail.med.upenn.edu") ||
             userinfo['emailAddr'].ends_with?("uphs.upenn.edu") ||
             userinfo['emailAddr'].ends_with?("nursing.upenn.edu") ||
             userinfo['emailAddr'].ends_with?("email.chop.edu"))
        office ||= 'BIOMED'
      end
    end

    return office || 'VPL'
  end

  def self.addIlliadUser(user)

    db = TinyTds::Client.new(username: ENV['ILLIAD_USERNAME'], password: ENV['ILLIAD_PASSWORD'], host: ENV['ILLIAD_DBHOST'], database: ENV['ILLIAD_DATABASE'])

    tablename = ENV['ILLIAD_ENV'] == 'production' ? 'usersall' : 'users'

    userinfo = user.data
    department = userinfo['dept'].respond_to?(:join) ? userinfo['dept'].join('|') : userinfo['dept']
    username = db.escape userinfo['proxied_for']

    query = %Q{INSERT INTO #{tablename}
                 (username, lastname, firstname, ssn, status, emailaddress, phone, department,
                  nvtgc, password, notificationmethod, deliverymethod, loandeliverymethod, cleared, web, address, authtype, articlebillingcategory, loanbillingcategory )
                 VALUES
                 ('#{username}', '#{db.escape userinfo['last_name']}', '#{db.escape userinfo['first_name']}', '#{db.escape userinfo['penn_id']}', '#{db.escape userinfo['status']}', '#{db.escape userinfo['emailAddr']}', '#{db.escape userinfo['phone']}', '#{db.escape department}', '#{db.escape userinfo['illoffice']}', '#{ENV['ILLIAD_USER_PASSWORD_HASH']}', 'Electronic', 'Mail to Address','Hold for Pickup','Yes', 'Yes', '#{db.escape userinfo['delivery']}', 'ILLiad', 'Exempt', 'Exempt' )
    }

    result = db.execute(query).do

    query = %Q{INSERT INTO usernotifications ( username, activitytype, notificationtype )
            VALUES
            ('#{username}', 'ClearedUser', 'Email'),
            ('#{username}', 'PasswordReset', 'Email'),
            ('#{username}', 'RequestCancelled', 'Email'),
            ('#{username}', 'RequestOther', 'Email'),
            ('#{username}', 'RequestOverdue', 'Email'),
            ('#{username}', 'RequestPickup', 'Email'),
            ('#{username}', 'RequestShipped', 'Email'),
            ('#{username}', 'RequestElectronicDelivery', 'Email')
    }

    result = db.execute(query).do

    db.close
  end

  def self.updateIlliadUser(user)
    db = TinyTds::Client.new(username: ENV['ILLIAD_USERNAME'], password: ENV['ILLIAD_PASSWORD'], host: ENV['ILLIAD_DBHOST'], database: ENV['ILLIAD_DATABASE'])

    tablename = ENV['ILLIAD_ENV'] == 'production' ? 'usersall' : 'users'

    userinfo = user.data
    department = userinfo['dept'].respond_to?(:join) ? userinfo['dept'].join('|') : (userinfo['dept'] || '')

    query = %Q{UPDATE #{tablename}
                SET    emailaddress = '#{db.escape userinfo['emailAddr']}',
                       phone        = '#{db.escape userinfo['phone']}',
                       department   = '#{db.escape department}',
                       nvtgc        = '#{db.escape userinfo['illoffice']}',
                       status       = '#{db.escape userinfo['status']}',
                       address      = '#{db.escape userinfo['delivery']}'
                WHERE  username = '#{db.escape userinfo['proxied_for']}'
    }

    result = db.execute(query)

    db.close
  end

  def self.submit(user, bib_data, params)

    userinfo = user.data

    if bib_data['requesttype'] != 'ScanDelivery' && !params['bibid'].presence.nil?
      bib_data['comments'] += "\n#{FranklinAvailability.getAvailabilityNotes(params['bibid'].presence)}\n"
    end

    bib_data['comments'] += '  Proxied by ' + userinfo['proxied_by'] if userinfo['proxied_by'] != userinfo['proxied_for']

    illserver = "http://#{ENV['ILLIAD_DBHOST']}/illiad/illiad.dll"

    body = {ILLiadForm: 'Logon', Username: userinfo['proxied_for'], Password: ENV['ILLIAD_USER_PASSWORD'], SubmitButton: 'Logon to ILLiad'}
    res = HTTParty.post(illserver, body: body)

    sessionid = /=(.*);/.match(res.headers['set-cookie'])[1]
    headers = {'Cookie' => "ILLiadSessionID=#{sessionid}"}

    if(bib_data['requesttype'].downcase == 'book')
      body = {ILLiadForm: 'LoanRequest',
              Username: userinfo['proxied_for'],
              SessionID: sessionid,
              LoanAuthor: bib_data['author'],
              LoanTitle: bib_data['booktitle'],
              LoanPublisher: bib_data['publisher'],
              LoanPlace: bib_data['place'],
              LoanDate: bib_data['rftdate'].presence || bib_data['year'].presence,
              LoanEdition: bib_data['edition'],
              ISSN: bib_data['isbn'],
              ESPNumber: bib_data['pmid'],
              NotWantedAfter: '12/31/2010',
              Notes: bib_data['comments'],
              CitedIn: bib_data['sid'],
              SubmitButton: 'Submit Request'}
    elsif(bib_data['requesttype'] == 'ScanDelivery')
      bib_data['chaptitle'] = 'none supplied' if bib_data['chaptitle'].presence.nil?

      body = {IlliadForm: 'ArticleRequest',
              Username: userinfo['proxied_for'],
              SessionID: sessionid,
              PhotoJournalTitle: bib_data['title'],
              PhotoJournalVolume: bib_data['volume'],
              PhotoJournalIssue: bib_data['issue'],
              PhotoJournalMonth: bib_data['pmonth'],
              PhotoJournalYear: bib_data['rftdate'].presence || bib_data['year'].presence,
              PhotoJournalInclusivePages: bib_data['pages'],
              ISSN: bib_data['issn'].presence || bib_data['isbn'].presence,
              ESPNumber: bib_data['pmid'],
              PhotoArticleAuthor: bib_data['author'],
              PhotoArticleTitle: bib_data['chaptitle'],
              NotWantedAfter: '12/31/2010',
              Notes: bib_data['comments'],
	      CitedIn: bib_data['sid'],
	      SubmitButton: 'Submit Request'}
    else
      illiadreqtype = 'ArticleRequest'
      illiadreqtype = 'BookChapterRequest' unless bib_data['requesttype'].index('chapter').nil?
      illiadreqtype = 'ConferencePaperRequest' unless bib_data['requesttype'].index('conference').nil?

      body = {ILLiadForm: illiadreqtype,
              Username: userinfo['proxied_for'],
              SessionID: sessionid,
              PhotoJournalTitle: bib_data['journal'],
              PhotoJournalVolume: bib_data['volume'],
              PhotoJournalIssue: bib_data['issue'],
              PhotoJournalMonth: bib_data['pmonth'],
              PhotoJournalYear: bib_data['rftdate'],
              PhotoJournalInclusivePages: bib_data['pages'],
              ISSN: bib_data['issn'],
              ESPNumber: bib_data['pmid'],
              PhotoArticleAuthor: bib_data['author'],
              PhotoArticleTitle: bib_data['article'],
              NotWantedAfter: '12/31/2010',
              Notes: bib_data['comments'],
	      CitedIn: bib_data['sid'],
	      SubmitButton: 'Submit Request'}
    end

    res = HTTParty.post(illserver, body: body, headers: headers)
    #/<span class="statusError">(.*)<\/span>/.match(res).nil? should be true unless error with values POSTed to ILLiad
    txnumber = /Transaction Number (\d+)\<\/span>/.match(res)[1]

    return txnumber
  end

end
