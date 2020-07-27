class PennCommunity

  def self.lookup(id = nil)
    raise 'ERROR: No ID provided' if id.nil?

    dbh = connection # TODO: validate connection?
    results = get_user_info id, dbh
    dbh.disconnect
    parse_query_results results
  end

  # @return [Hash]
  # @param [String] id either a PennKey or PennID
  # @param [DBI::DatabaseHandle] db handle
  def self.get_user_info(id = nil, dbh = connection)
    # determine what type of credential is supplied and set limit for WHERE clause accordingly
    limit ||= "AND SAV.V_PENN_ID = '#{id}'" unless (id =~ /^\d+/).nil?
    limit ||= "AND SMV.V_KERBEROS_PRINCIPAL = '#{id}'" unless (id =~ /^\w/).nil?
    raise 'ERROR: Invalid ID provided' if limit.nil?
    
    # Retrieve the records from PennCommunity
    query = user_query(limit)
    dbh.execute query
  end

  # @param [DBI::StatementHandle] results
  def self.parse_query_results(results)
    keys = results.column_names # array of column names, e.g., ["PENN_ID", "AFFILIATION_ACTIVE_CODE", "AFFILIATION_CODE", "PENNKEY_ACTIVE_CODE", "PENNKEY", "FIRST_NAME", "MIDDLE_NAME", "LAST_NAME", "EMAIL", "ORG_ACTIVE_CODE", "ORG_CODE", "DEPT", "RANK"]
    user_info = Hash[keys.zip(Array.new(keys.length) { [] })] # builds hash with keys from column names and values as empty arrays
    results.reduce(user_info) { |l, r| l.merge!(r.to_h) { |_k, lv, rv| lv << rv.to_s } } # populates array values from results
    # userinfo now looks like...
    # {"PENN_ID"=>["51977820"],
    #  "AFFILIATION_ACTIVE_CODE"=>["A"],
    #  "AFFILIATION_CODE"=>["STAF"],
    #  "PENNKEY_ACTIVE_CODE"=>["A"],
    #  "PENNKEY"=>["mkanning"],
    #  "FIRST_NAME"=>["Michael"],
    #  "MIDDLE_NAME"=>[""],
    #  "LAST_NAME"=>["Kanning"],
    #  "EMAIL"=>["mkanning@upenn.edu"],
    #  "ORG_ACTIVE_CODE"=>["A-F"],
    #  "ORG_CODE"=>["5008"],
    #  "DEPT"=>["Library Computing Systems"],
    #  "RANK"=>["Staff"]}
    user_info = Hash[user_info.map { |k, v| [k.downcase, v] }]
    name_index = user_info['first_name'].index { |i| !i.blank? }

    ['first_name', 'middle_name', 'last_name'].each do |f|
      user_info[f] = name_index.nil? ? '' : user_info[f][name_index]
    end

    ['dept', 'rank'].each do |f|
      user_info[f] = user_info[f].reject(&:blank?).map(&:rstrip)
    end


    ['affiliation_active_code', 'affiliation_code', 'org_active_code', 'org_code'].each do |f|
      user_info[f] = user_info[f].reject(&:blank?)
    end

    ['penn_id', 'pennkey', 'pennkey_active_code', 'email'].each do |f|
      user_info[f] = user_info[f].last || ''
    end

    user_info
    # Example return value:
    # {"penn_id"=>"12345678", "affiliation_active_code"=>["A"], "affiliation_code"=>["STAF"], "pennkey_active_code"=>"A",
    # "pennkey"=>"mkanning", "first_name"=>"Michael", "middle_name"=>"", "last_name"=>"Kanning",
    # "email"=>"mkanning@upenn.edu", "org_active_code"=>["A-F"], "org_code"=>["5008"],
    # "dept"=>["Library Computing Systems"], "rank"=>["Staff"]}
  end

  def self.connection
    DBI.connect(ENV['PCOM_DBI'], ENV['PCOM_USERNAME'], ENV['PCOM_PASSWORD'])
  end

  # Establish querystring to retrieve the record(s) for this PennKey or PennID
  # @param [String] limit
  def self.user_query(limit)
    %(
    /* CHOP */
      SELECT
        SAV.V_PENN_ID AS PENN_ID,
        SAV.V_ACTIVE_CODE AS AFFILIATION_ACTIVE_CODE,
        SAV.V_AFFILIATION_CODE AS AFFILIATION_CODE,
        SMV.V_ACTIVE_CODE AS PENNKEY_ACTIVE_CODE,
        SMV.V_KERBEROS_PRINCIPAL AS PENNKEY,
        INITCAP(SAV.V_FIRST_NAME) AS FIRST_NAME,
        INITCAP(SAV.V_MIDDLE_NAME) AS MIDDLE_NAME,
        INITCAP(SAV.V_LAST_NAME) AS LAST_NAME,
        LOWER(PD.EMAIL_ADDRESS) AS EMAIL,
        'A' AS ORG_ACTIVE_CODE,
        'CHOP' AS ORG_CODE,
        'CHOP' AS DEPT,
        'CHOP' AS RANK
      FROM
        DCCSADMIN.PERSON_DIRECTORY PD,
        COMADMIN.SSN4_AFFILIATION_VIEW SAV,
        COMADMIN.SSN4_MEMBER_VIEW SMV
      WHERE SAV.V_AFFILIATION_CODE = 'CHOP'
        AND SAV.V_PENN_ID = PD.PENN_ID(+)
        AND SAV.V_PENN_ID = SMV.V_PENN_ID
        #{limit}
      UNION
    /* UPHS */
      SELECT SAV.V_PENN_ID AS PENN_ID,
        SAV.V_ACTIVE_CODE AS AFFILIATION_ACTIVE_CODE,
        SAV.V_AFFILIATION_CODE AS AFFILIATION_CODE,
        SMV.V_ACTIVE_CODE AS PENNKEY_ACTIVE_CODE,
        SMV.V_KERBEROS_PRINCIPAL AS PENNKEY,
        INITCAP(SAV.V_FIRST_NAME) AS FIRST_NAME,
        INITCAP(SAV.V_MIDDLE_NAME) AS MIDDLE_NAME,
        INITCAP(SAV.V_LAST_NAME) AS LAST_NAME,
        LOWER(PD.EMAIL_ADDRESS) AS EMAIL,
        SAV.V_ASSOC_PAY_EMPLOYEE_STATUS AS ORG_ACTIVE_CODE,
        SAV.V_ASSOC_PAY_PROCESS_LEVEL AS ORG_CODE,
        SAV.V_ASSOC_PAY_DEPARTMENT_NAME AS DEPT,
        SAV.V_ASSOC_PAY_STATUS_DESCR AS RANK
      FROM
        DCCSADMIN.PERSON_DIRECTORY PD,
        COMADMIN.SSN4_AFFILIATION_VIEW SAV,
        COMADMIN.SSN4_MEMBER_VIEW SMV
      WHERE SAV.V_SOURCE = 'UPHS'
        AND SAV.V_PENN_ID = PD.PENN_ID(+)
        AND SAV.V_PENN_ID = SMV.V_PENN_ID(+)
        #{limit}
      UNION
    /* STAF or TEMP or PGUE */
      SELECT SAV.V_PENN_ID AS PENN_ID,
        SAV.V_ACTIVE_CODE AS AFFILIATION_ACTIVE_CODE,
        SAV.V_AFFILIATION_CODE AS AFFILIATION_CODE,
        SMV.V_ACTIVE_CODE AS PENNKEY_ACTIVE_CODE,
        SMV.V_KERBEROS_PRINCIPAL AS PENNKEY,
        INITCAP(SAV.V_FIRST_NAME) AS FIRST_NAME,
        INITCAP(SAV.V_MIDDLE_NAME) AS MIDDLE_NAME,
        INITCAP(SAV.V_LAST_NAME) AS LAST_NAME,
        LOWER(PD.EMAIL_ADDRESS) AS EMAIL,
        SAV.V_PENN_PAY_EMPLOYMENT_STATUS || '-' || SAV.V_PENN_PAY_FT_PT_CODE AS ORG_ACTIVE_CODE,
        SAV.V_PENN_PAY_ORG AS ORG_CODE,
        O.DESCRIPTION AS DEPT,
        'Staff' AS RANK
      FROM
        DCCSADMIN.PERSON_DIRECTORY PD,
        COMADMIN.SSN4_AFFILIATION_VIEW SAV,
        COMADMIN.SSN4_MEMBER_VIEW SMV,
        PCADMIN.ORGANIZATION O
      WHERE SAV.V_AFFILIATION_CODE IN ('STAF','TEMP')
        AND SAV.V_PENN_ID = SMV.V_PENN_ID(+)
        AND SAV.V_PENN_ID = PD.PENN_ID(+)
        AND SAV.V_PENN_PAY_ORG = O.ORGANIZATION_CODE(+)
        #{limit}
      UNION
    /* FAC */
      SELECT SAV.V_PENN_ID AS PENN_ID,
        SAV.V_ACTIVE_CODE AS AFFILIATION_ACTIVE_CODE,
        SAV.V_AFFILIATION_CODE AS AFFILIATION_CODE,
        SMV.V_ACTIVE_CODE AS PENNKEY_ACTIVE_CODE,
        SMV.V_KERBEROS_PRINCIPAL AS PENNKEY,
        INITCAP(SAV.V_FIRST_NAME) AS FIRST_NAME,
        INITCAP(SAV.V_MIDDLE_NAME) AS MIDDLE_NAME,
        INITCAP(SAV.V_LAST_NAME) AS LAST_NAME,
        LOWER(PD.EMAIL_ADDRESS) AS EMAIL,
        SAV.V_PENN_PAY_EMPLOYMENT_STATUS || '-' || SAV.V_PENN_PAY_FT_PT_CODE AS ORG_ACTIVE_CODE,
        SAV.V_PENN_PAY_ORG AS ORG_CODE,
        O.DESCRIPTION AS DEPT,
        'Faculty' AS RANK
      FROM
        DCCSADMIN.PERSON_DIRECTORY PD,
        COMADMIN.SSN4_AFFILIATION_VIEW SAV,
        COMADMIN.SSN4_MEMBER_VIEW SMV,
        PCADMIN.ORGANIZATION O
      WHERE SAV.V_AFFILIATION_CODE = 'FAC'
        AND SAV.V_PENN_ID = SMV.V_PENN_ID(+)
        AND SAV.V_PENN_ID = PD.PENN_ID(+)
        AND SAV.V_PENN_PAY_ORG = O.ORGANIZATION_CODE(+)
        #{limit}
      UNION
    /* STU */
      SELECT SAV.V_PENN_ID AS PENN_ID,
        SAV.V_ACTIVE_CODE AS AFFILIATION_ACTIVE_CODE,
        SAV.V_AFFILIATION_CODE AS AFFILIATION_CODE,
        SMV.V_ACTIVE_CODE AS PENNKEY_ACTIVE_CODE,
        SMV.V_KERBEROS_PRINCIPAL AS PENNKEY,
        INITCAP(SAV.V_FIRST_NAME) AS FIRST_NAME,
        INITCAP(SAV.V_MIDDLE_NAME) AS MIDDLE_NAME,
        INITCAP(SAV.V_LAST_NAME) AS LAST_NAME,
        LOWER(PD.EMAIL_ADDRESS) AS EMAIL,
        SAV.V_SRS_ACTIVE_CODE AS ORG_ACTIVE_CODE,
        SAV.V_SRS_DIVISION AS ORG_CODE,
        SAV.V_SRS_MAJOR_CODE AS DEPT,
        SAV.V_SRS_STUDENT_CLASS AS RANK
      FROM
        COMADMIN.SSN4_MEMBER_VIEW SMV,
        COMADMIN.SSN4_AFFILIATION_VIEW SAV,
        DCCSADMIN.PERSON_DIRECTORY PD
      WHERE SAV.V_PENN_ID = SMV.V_PENN_ID
        AND SAV.V_AFFILIATION_CODE = 'STU'
        AND SAV.V_PENN_ID = PD.PENN_ID(+)
        #{limit}
      UNION
    /* OTHERS */
      SELECT SAV.V_PENN_ID AS PENN_ID,
        SAV.V_ACTIVE_CODE AS AFFILIATION_ACTIVE_CODE,
        SAV.V_AFFILIATION_CODE AS AFFILIATION_CODE,
        SMV.V_ACTIVE_CODE AS PENNKEY_ACTIVE_CODE,
        SMV.V_KERBEROS_PRINCIPAL AS PENNKEY,
        INITCAP(SAV.V_FIRST_NAME) AS FIRST_NAME,
        INITCAP(SAV.V_MIDDLE_NAME) AS MIDDLE_NAME,
        INITCAP(SAV.V_LAST_NAME) AS LAST_NAME,
        LOWER(PD.EMAIL_ADDRESS) AS EMAIL,
        '' AS ORG_ACTIVE_CODE,
        '' AS ORG_CODE,
        '' AS DEPT,
        '' AS RANK
      FROM COMADMIN.SSN4_MEMBER_VIEW SMV, COMADMIN.SSN4_AFFILIATION_VIEW SAV,DCCSADMIN.PERSON_DIRECTORY PD
      WHERE SAV.V_PENN_ID = SMV.V_PENN_ID
        AND (SAV.V_AFFILIATION_CODE NOT IN ('CHOP','FAC','STAF','STU','TEMP') AND V_SOURCE <> 'UPHS')
        AND SAV.V_PENN_ID = PD.PENN_ID(+)
        #{limit}
    )
  end
end
