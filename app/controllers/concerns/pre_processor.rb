module PreProcessor

  def pre_process(form_id, params)
    case form_id
      when 'fixit', 'enhanced', 'course', 'booksbymail', 'inprocess', 'onorder', 'booksbymail'
        #username, _ = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
        username = request.headers['HTTP_REMOTE_USER']&.split('@')&.first || ''
        record = Alma::Bib.find([params[:bibid]], {expand: :p_avail})

        return {record: BibRecord.new((record.first.response unless record.has_error?)),
                user: User.new(username),
                params: params}

      when 'missing'
        username = request.headers['HTTP_REMOTE_USER']&.split('@')&.first || ''
        record = Alma::Bib.find([params[:bibid]], {expand: :p_avail})
        holdings = Alma::Bib.resources.almaws_v1_bibs.mms_id_holdings.get(Alma::Bib.query_merge(mms_id: params[:bibid]));
        #xml = Nokogiri::XML(Alma::Bib.resources.almaws_v1_bibs.get(Alma::Bib.query_merge(mms_id: params[:bibid], expand: 'p_avail')).body)
        #holding_tags = xml.xpath('.//datafield[@tag="AVA"]')
        #holdings = Hash[holding_tags.map {|h| 
          #[h.xpath('.//subfield[@code="t"]').text, h.xpath('.//subfield[@code="0"]').text]
        #}]

        return {record: BibRecord.new((record.first.response unless record.has_error?)),
                holdings: Hash[holdings['holdings']['holding'].map {|h| ["#{h['location']['desc']}", h['holding_id']]}],
                #holdings: Hash[holdings['holdings']['holding'].map {|h| ["#{h['call_number']} (#{h['location']['desc']})", h['holding_id']]}],
                #holdings: holdings,
                user: User.new(username),
                params: params}

      when 'aeon'

      when 'help'
        return {params: params}

      when 'resourcesharing'
        username = request.headers['HTTP_REMOTE_USER']&.split('@')&.first || ''

        return {user: User.new(username)}

      when 'ill', 'facultyexpress'
        #username, _ = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
        username = request.headers['HTTP_REMOTE_USER']&.split('@')&.first || ''
        proxy_id = nil

        unless params['upennproxyid'].nil? || params['upennproxyid'].empty?
          proxy_id = params['upennproxyid']
        end

        user = User.new(username, proxy_id)
        Illiad.getIlliadUserInfo(user, params)

        record = Illiad.getBibData(params)
        delivery_method = record['requesttype'] == 'Book' ? "Pickup at #{user.data['illoffice_name']}" : 'Web Delivery'
        show_addr_msg = false

        if user.data['status'] == 'StandingFaculty'
          Illiad.getCorrectedDeptDetails(user.data)
          if record['requesttype'] == 'Book'
            delivery_method = "Deliver to my department: #{user.data['delivery']}" if record['requesttype'] == 'Book'
            show_addr_msg = true
          end
        end

        return {record: record,
                user: user,
                delivery_method: delivery_method,
                show_addr_message: show_addr_msg,
                params: params}

      else
        # TODO probably should email an admin here
        raise
    end
  end

end
