class Illiad

  class IlliadValidationError < StandardError; end

  # These options are used by Illiad rules to properly route requests.
  # Do not alter them without first consulting ILL staff.
  ILL_PICKUP_LOCATIONS = [
    ['Van Pelt Library'],
    ['Lockers at Van Pelt Library', 'Lockers at Van Pelt'],
    ['Annenberg Library'],
    ['Biotech Commons'],
    ['Chemistry Library'],
    ['Dental Medicine Library', 'Dental Library'],
    ['Lockers at Dental Medicine Library', 'Lockers at Dental'],
    ['Fisher Fine Arts Library', 'Fine Arts Library'],
    ['Library at the Katz Center', 'Katz Library'],
    ['Math/Physics/Astronomy Library'],
    ['Museum Library'],
    ['New Bolton Center'],
    ['Pennsylvania Hospital Library', 'PA Hospital Library'],
    ['Veterinary Medicine Library', 'Veterinary Library']
  ].freeze

  ILL_FACEX_DELIVERY_OPTIONS = [
    ['Office Delivery', 'office'],
    ['Books by Mail', 'bbm']
  ].freeze

  @illoffices = Hash.new() { 'Van Pelt Library' }
  @illoffices['BIOMED'] = 'Biomedical Library'
  @illoffices['DENTAL'] = 'Dental Medicine Library'
  @illoffices['VET'] = 'Veterinary Medicine Library'

  # no DB
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
      if ['article', 'book'].member?(bib_data['requesttype'])
        bib_data['requesttype'][0] = bib_data['requesttype'][0].upcase
      end
    end

    bib_data['chaptitle'] = params['chaptitle'].presence
    bib_data['booktitle'] = params['title'].presence     || params['Book'].presence        || params['bookTitle'].presence || params['booktitle'].presence || params['rft.title'].presence || ''
    bib_data['edition']   = params['edition'].presence   || params['rft.edition'].presence || ''
    bib_data['publisher'] = params['publisher'].presence || params['Publisher'].presence   || params['rft.pub'].presence   || ''
    bib_data['place']     = params['place'].presence     || params['PubliPlace'].presence  || params['rft.place'].presence || ''
    bib_data['an']        = params['AN'].presence        || ''
    bib_data['py']        = params['PY'].presence        || ''
    bib_data['pb']        = params['PB'].presence        || ''
    bib_data['journal']   = params['Journal'].presence   || params['journal'].presence     || params['rft.btitle'].presence || params['rft.jtitle'].presence || params['rft.title'].presence || params['title'].presence || ''
    bib_data['article']   = params['Article'].presence   || params['article'].presence     || params['atitle'].presence     || params['rft.atitle'].presence || ''
    bib_data['pmonth']    = params['pmonth'].presence    || params['rft.month'].presence   ||''
    bib_data['rftdate']   = params['rftdate'].presence   || params['rft.date'].presence
    bib_data['year']      = params['Year'].presence      || params['year'].presence || params['rft.year'] || params['rft.pubyear'].presence || params['rft.pubdate'].presence
    bib_data['volume']    = params['Volume'].presence    || params['volume'].presence      || params['rft.volume'].presence || ''
    bib_data['issue']     = params['Issue'].presence     || params['issue'].presence       || params['rft.issue'].presence  || ''
    bib_data['issn']      = params['issn'].presence      || params['ISSN'].presence        || params['rft.issn'].presence   ||''
    bib_data['isbn']      = params['isbn'].presence      || params['ISBN'].presence        || params['rft.isbn'].presence   || ''
    bib_data['sid']       = params['sid'].presence       || params['rfr_id'].presence      || ''
    bib_data['pid']       = params['pid'].presence       || ''
    bib_data['source']    = params['source'].presence    || 'direct'
    bib_data['comments']  = params['UserId'].presence    || params['comments'].presence    || ''
    bib_data['bibid']     = params['record_id'].presence || params['id'].presence          || params['bibid'].presence      || ''

    # Handles IDs coming like pmid:numbersgohere
    unless params['rft_id'].presence.nil?
      parts = params['rft_id'].split(':')
      bib_data[parts[0]] = parts[1]
    end

    # *** Relais/BD sends dates through as rft.date but it may be a book request ***
    if(bib_data['sid'] == 'BD' && bib_data['requesttype'] == 'Book')
      bib_data['year'] = params['date'].presence || bib_data['rftdate']
    end

    # if rftdate is not ONLY a year it probably should be - Illiad likes it that way
    # use the 'year' field if present - per Lapis/MK 4/2022
    if (bib_data['rftdate']&.length != 4) && bib_data['year'].present?
      year = bib_data['year'].gsub(/\D/, '')
      bib_data['rftdate'] = year
    end

    ## Lookup record in Alma on submit?

    # *** Make the bookitem booktitle the journal title ***
    bib_data['journal'] = params['bookTitle'].presence || bib_data['journal'] if bib_data['requesttype'] == 'bookitem';

    # *** scan delivery uses journal title || book title, which ever we have ***
    # *** we should only have one of them ***
    bib_data['title'] = bib_data['booktitle'].presence || bib_data['journal'].presence;

    # *** Make a non-inclusive page parameter ***
    bib_data['spage'] = params['Spage'].presence || params['spage'].presence || params['rft.spage'].presence || '';
    bib_data['epage'] = params['Epage'].presence || params['epage'].presence || params['rft.epage'].presence || '';

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

  # queries DB
  def self.getIlliadUserInfo(user, params)

    db = TinyTds::Client.new(username: ENV['ILLIAD_USERNAME'], password: ENV['ILLIAD_PASSWORD'], host: ENV['ILLIAD_DBHOST'], database: ENV['ILLIAD_DATABASE'])

    tablename = Rails.env.production? ? 'usersall' : 'users'

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

    ill_office = getILLOffice(userinfo)

    if result['status'].nil?
      userinfo['illiadrecord'] = 'new'
      userinfo['illoffice'] = ill_office
      #userinfo['delivery'] = getDeliveryAddr(userinfo) || ''
    elsif userinfo['dept'] != result['department'] ||
          userinfo['illoffice'] != result['nvtgc'] ||
          userinfo['status'] != result['status'] ||
          userinfo['emailAddr'] != result['emailaddress'] ||
          userinfo['phone'] != result['phone']
      userinfo['illiadrecord'] = 'modify'
      userinfo['dept'] = result['department']
      userinfo['illoffice'] = result['nvtgc'] || ill_office
      userinfo['delivery'] = result['address'] || userinfo['delivery']
      userinfo['status'] = result['status'] || userinfo['status']
    else
      userinfo['illiadrecord'] = 'nochange'
    end

    userinfo['illoffice_name'] = @illoffices[userinfo['illoffice']]

    db.close

    return userinfo
  end

  # no DB
  # @param [Hash] userinfo
  def self.getCorrectedDeptDetails(userinfo)
    return nil if userinfo['status'] != 'StandingFaculty'

    # not sure what to expect in userinfo, but this will address errors
    return 'VPL' unless userinfo['org_active_code'].respond_to? :each_with_index

    active_i = userinfo['org_active_code'].each_with_index.reject {|v,_i| v == 'I'} .map {|v| v[1]}
    corrected = active_i.map {|v| DeptMapping[userinfo['org_code'][v]]} .compact.first
    unless(corrected.nil?)
      userinfo['dept'] = corrected[:dept]
      userinfo['mailing_addr'] = corrected[:address]
    end
  end

  # no DB
  def self.getILLOffice(userinfo)
    office = nil
    # not sure what to expect in userinfo, but this will address errors
    return 'VPL' unless userinfo['org_active_code'].respond_to? :each_with_index

    # get index of active code in returned array values
    active_i = userinfo['org_active_code'].each_with_index.reject { |v, _i| v == 'I' } .map { |v| v[1] }
    active_i.each do |i|
      org_code = userinfo['org_code'][i]
      # check for VET attributes
      if ['5021','VEM','VET','VTP'].member?(org_code) ||
         !(org_code =~ /58\d\d/).nil? ||
         userinfo['emailAddr'].end_with?('@vet.upenn.edu')
        office ||= 'VET'
      # check for DENTAL attributes
      elsif ['5020','DEN','DPH'].member?(org_code) ||
            !(org_code =~ /51\d\d/).nil? ||
            userinfo['emailAddr'].end_with?('@dental.upenn.edu') ||
            userinfo['emailAddr'].end_with?('@biochem.dental.upenn.edu')
        office ||= 'DENTAL'
      # check for BIOMED attributes
      elsif %w[BFC CCA CCNJ CNTRT CORP CPUP CPUPH GAMBR HUP JRB MDPAH MDPMC MDUPM MGMT MHUP MPAH MPMC PAH PAHHM PERFS PMC SCON TPHX TPHXD URSVC 5019 BMP MDP MED NRP NUG NUR NUP PDM CHOP].member?(org_code) ||
            !(org_code =~ /4\d\d\d/).nil? ||
            userinfo['emailAddr'].end_with?('mail.med.upenn.edu') ||
            userinfo['emailAddr'].end_with?('uphs.upenn.edu') ||
            userinfo['emailAddr'].end_with?('nursing.upenn.edu') ||
            userinfo['emailAddr'].end_with?('email.chop.edu')
        office ||= 'BIOMED'
      end
    end

    return office || 'VPL'
  end

  # queries DB
  def self.addIlliadUser(user)

    db = TinyTds::Client.new(username: ENV['ILLIAD_USERNAME'], password: ENV['ILLIAD_PASSWORD'], host: ENV['ILLIAD_DBHOST'], database: ENV['ILLIAD_DATABASE'])

    tablename = Rails.env.production? ? 'usersall' : 'users'

    userinfo = user.data
    department = userinfo['dept'].respond_to?(:join) ? userinfo['dept'].join('|') : userinfo['dept']
    unescaped_username = userinfo['proxied_for']
    unless unescaped_username
      raise ArgumentError, "addIlliadUser called with no username available! user_info: #{userinfo}"
    end

    username = db.escape unescaped_username # throws exception if #escape is sent nil

    # Very Important Note
    # As of 12/09/2020, we learned that creating Users in this way is not good. Particularly how
    # we set the password value to a static value. As of Illiad 9.0, the hashing algorithm changed and
    # now as of version 9.1 these old hashed password values are seen as invalid and the Illiad web
    # forms force a password update. This breaks our request submission behavior here, which is no good.
    # Illiad has added a database trigger to change the current hashed password value we use to a properly
    # hashed value. This allows us to continue this bad behavior until we can move to make use of Illiad
    # API methods for user creation and transaction submission.
    # tl;dr: don't change the hashed password value used here or you'll break everything

    query = %Q{INSERT INTO #{tablename}
                 (username, lastname, firstname, ssn, status, emailaddress, phone, department,
                  nvtgc, password, notificationmethod, deliverymethod, loandeliverymethod, cleared, web, address, authtype, articlebillingcategory, loanbillingcategory )
                 VALUES
                 ('#{username}', '#{db.escape userinfo['last_name']}', '#{db.escape userinfo['first_name']}', '#{db.escape userinfo['penn_id']}', '#{db.escape userinfo['status']}', '#{db.escape userinfo['emailAddr']}', '#{db.escape userinfo['phone']}', '#{db.escape department}', '#{db.escape userinfo['illoffice']}', '#{ENV['ILLIAD_USER_PASSWORD_HASH']}', 'Electronic', 'Mail to Address','Hold for Pickup','Yes', 'Yes', '#{db.escape userinfo['delivery']}', 'Default', 'Exempt', 'Exempt' )
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

  # queries DB
  def self.updateIlliadUser(user)
    db = TinyTds::Client.new(username: ENV['ILLIAD_USERNAME'], password: ENV['ILLIAD_PASSWORD'], host: ENV['ILLIAD_DBHOST'], database: ENV['ILLIAD_DATABASE'])

    tablename = Rails.env.production? ? 'usersall' : 'users'

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

  # uses web service
  def self.submit(user, bib_data, params)

    userinfo = user.data

    if bib_data['requesttype'] != 'ScanDelivery' && !params['bibid'].presence.nil?
      bib_data['comments'] += "\n#{FranklinAvailability.getAvailabilityNotes(params['bibid'].presence)}\n"
    end

    if userinfo['proxied_by'] != userinfo['proxied_for']
      bib_data['comments'] += "\nProxied by #{userinfo['proxied_by']}"
    end

    if (params[:receipt_method] == 'delivery' && params[:delivery_selection] == 'bbm') && userinfo['status'] == User::FACEX_STATUS
      bib_data['comments'] += "\nDelivery Choice: Faculty Express patron requests BBM/UPS delivery for this loan"
    end

    illserver = "https://#{ENV['ILLIAD_DBHOST']}/illiad/illiad.dll"

    body = {ILLiadForm: 'Logon', Username: userinfo['proxied_for'], Password: ENV['ILLIAD_USER_PASSWORD'], SubmitButton: 'Logon to ILLiad'}

    if Rails.env.development?
      headers = {'Cookie' => "ILLiadSessionID=test-session"}
    else
      res = HTTParty.post(illserver, body: body, verify: false)
      sessionid = /ILLiadSessionID=(.*); path=\/; HttpOnly; Secure/.match(res.headers['set-cookie'])[1]
      headers = {'Cookie' => "ILLiadSessionID=#{sessionid}"}
    end

    # deliverytype either comes from Franklin as 'bbm' param
    # or is set by the Delivery Options drop down in the book request version
    # of the ILL form. we ship this to ILLiad via the item_info_1 field
    item_info_1 = if (params[:deliverytype] == 'bbm' || params[:delivery] == 'bbm') ||
                     (params[:receipt_method] == 'delivery' && params[:delivery_selection] == 'bbm')
                    # explicit BBM case (user clicked 'Books by Mail' in Franklin) OR
                    # BBM was chosen as ILL delivery option
                    'Books by Mail'
                  else
                    # FacEx Office Delivery case - send BBM in ItemInfo1 so the request is routed appropriately
                    if params[:receipt_method] == 'delivery' && params[:delivery_selection] == 'office'
                      'Books by Mail'
                    end

                    # User has selected a pickup location - send it in the Item Info 1 field
                    # after validation
                    if ILL_PICKUP_LOCATIONS.collect { |loc| loc[1] || loc[0] }.include? params[:pickup_location]
                      params[:pickup_location]
                    end
                  end

    # if the request is explicitly BBM, and we're sure its a 'book' request, prepend the BBM
    # We *don't* want to set this when an ILL request is chosen by the user to be delivered via "Books by Mail"
    if params[:deliverytype] == 'bbm' && params[:requesttype].downcase == 'book'
      bib_data['booktitle'] = bib_data['booktitle'].prepend 'BBM '
    end

    if bib_data['requesttype'].downcase == 'book'
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
              ItemInfo1: item_info_1,
              SubmitButton: 'Submit Request'}
    elsif bib_data['requesttype'] == 'ScanDelivery'
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

    if Rails.env.development?
      txnumber = 'test-txnumber'
    else
      begin
        res = HTTParty.post(illserver, body: body, headers: headers)
        #/<span class="statusError">(.*)<\/span>/.match(res).nil? should be true unless error with values POSTed to ILLiad
        txnumber = /Transaction Number (\d+)\<\/span>/.match(res)[1]
      rescue NoMethodError => e

        if txnumber.blank?
          # look for a statusError
          illiad_response_page = Nokogiri::HTML res
          status_errors = illiad_response_page.css('.statusError')
        end

        if status_errors&.present?
          raise IlliadValidationError,
                "Validation errors in Illiad transaction: #{status_errors.map(&:content).join(', ')}"
        else
          raise StandardError,
                "Failed to get txnumber on Illiad submission. Illiad response: #{res}. Original exception: #{e.message}"
        end
      end
    end

    return txnumber
  end

end
