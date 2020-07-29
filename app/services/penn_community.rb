class PennCommunity

  # Example return value:
  # {"penn_id"=>"12345678", "affiliation_active_code"=>["A"], "affiliation_code"=>["STAF"], "pennkey_active_code"=>"A",
  # "pennkey"=>"mkanning", "first_name"=>"Michael", "middle_name"=>"", "last_name"=>"Kanning",
  # "email"=>"mkanning@upenn.edu", "org_active_code"=>["A-F"], "org_code"=>["5008"],
  # "dept"=>["Library Computing Systems"], "rank"=>["Staff"]}
  # @return [Hash]
  def self.getUser(id = nil)

    # *** Determine if a credential is supplied, and what type it is *** 
    raise "ERROR: No ID provided" if id.nil?
 
    limit ||= "      AND SAV.V_PENN_ID = '#{id}'" unless (id =~ /^\d+/).nil?
    limit ||= "      AND SMV.V_KERBEROS_PRINCIPAL = '#{id}'" unless (id =~ /^\w/).nil?
    raise "ERROR: Invalid ID provided" if limit.nil?

    #   *** Get a database connection to PennCommunity ***
    dbh = DBI.connect(ENV['PCOM_DBI'], ENV['PCOM_USERNAME'], ENV['PCOM_PASSWORD']) or raise "ERROR: Unable to establish a connection to the database server"
    
    # *** Retrieve the record(s) for this PennKey or PennID ***
    
    statement = %Q(
    /* CHOP */
        SELECT SAV.V_PENN_ID AS PENN_ID,
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
        FROM (SELECT PENN_ID, EMAIL_ADDRESS
              FROM DIRADMIN.DIR_DETAIL_EMAIL_ADDRESS_V
              WHERE VIEW_TYPE = 'I' AND PREF_FLAG_EMAIL ='Y' ) PD,COMADMIN.SSN4_AFFILIATION_VIEW SAV, COMADMIN.SSN4_MEMBER_VIEW SMV
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
        FROM (SELECT PENN_ID, EMAIL_ADDRESS
              FROM DIRADMIN.DIR_DETAIL_EMAIL_ADDRESS_V
              WHERE VIEW_TYPE = 'I' AND PREF_FLAG_EMAIL ='Y' ) PD, COMADMIN.SSN4_AFFILIATION_VIEW SAV, COMADMIN.SSN4_MEMBER_VIEW SMV
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
        FROM (SELECT PENN_ID, EMAIL_ADDRESS
              FROM DIRADMIN.DIR_DETAIL_EMAIL_ADDRESS_V
              WHERE VIEW_TYPE = 'I' AND PREF_FLAG_EMAIL ='Y' ) PD, COMADMIN.SSN4_AFFILIATION_VIEW SAV, COMADMIN.SSN4_MEMBER_VIEW SMV, PCADMIN.ORGANIZATION O
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
        FROM (SELECT PENN_ID, EMAIL_ADDRESS
              FROM DIRADMIN.DIR_DETAIL_EMAIL_ADDRESS_V
              WHERE VIEW_TYPE = 'I' AND PREF_FLAG_EMAIL ='Y' ) PD, COMADMIN.SSN4_AFFILIATION_VIEW SAV, COMADMIN.SSN4_MEMBER_VIEW SMV, PCADMIN.ORGANIZATION O
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
        FROM COMADMIN.SSN4_MEMBER_VIEW SMV, COMADMIN.SSN4_AFFILIATION_VIEW SAV,
          (SELECT PENN_ID, EMAIL_ADDRESS
           FROM DIRADMIN.DIR_DETAIL_EMAIL_ADDRESS_V
           WHERE VIEW_TYPE = 'I' AND PREF_FLAG_EMAIL ='Y' ) PD
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
        FROM COMADMIN.SSN4_MEMBER_VIEW SMV, COMADMIN.SSN4_AFFILIATION_VIEW SAV,
             (SELECT PENN_ID, EMAIL_ADDRESS
              FROM DIRADMIN.DIR_DETAIL_EMAIL_ADDRESS_V
              WHERE VIEW_TYPE = 'I' AND PREF_FLAG_EMAIL ='Y' ) PD
        WHERE SAV.V_PENN_ID = SMV.V_PENN_ID
        AND (SAV.V_AFFILIATION_CODE NOT IN ('CHOP','FAC','STAF','STU','TEMP') AND V_SOURCE <> 'UPHS')
        AND SAV.V_PENN_ID = PD.PENN_ID(+)
        #{limit}
    )

    # *** Retrieve the records from PennCommunity ***
    rs = dbh.execute(statement)

    keys = rs.column_names
    userInfo = Hash[keys.zip(Array.new(keys.length) {[]})]

    rs.reduce(userInfo) {|l,r| l.merge!(r.to_h) {|k, lv, rv| lv << rv.to_s} }

    userInfo = Hash[userInfo.map{|k,v| [k.downcase, v]}]

    nameIdx = userInfo['first_name'].index {|i| !i.blank?}

    ['first_name', 'middle_name', 'last_name'].each {|f|
      userInfo[f] = nameIdx.nil? ? '' :  userInfo[f][nameIdx]
    }

    ['dept', 'rank'].each {|f|
      userInfo[f] = userInfo[f].reject(&:blank?).map(&:rstrip)
    }


    ['affiliation_active_code', 'affiliation_code', 'org_active_code', 'org_code'].each {|f|
      userInfo[f] = userInfo[f].reject(&:blank?)
    }

    ['penn_id', 'pennkey', 'pennkey_active_code', 'email'].each {|f|
      userInfo[f] = userInfo[f].reject(&:blank?).last || ''
    }

    dbh.disconnect if dbh

    return userInfo
  end
end
