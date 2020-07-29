module PreProcessor

  def pre_process(form_id, params)
    case form_id
      when 'fixit', 'enhanced', 'course', 'booksbymail', 'inprocess', 'onorder', 'booksbymail'
        #username, _ = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
        username = request.headers['HTTP_REMOTE_USER']&.split('@')&.first || ''
        record = Alma::Bib.find([params[:bibid]], {expand: :p_avail})
        holdings_response = Alma::Bib.resources.almaws_v1_bibs.mms_id_holdings.get(Alma::Bib.query_merge(mms_id: params[:bibid]));
        holdings = Hash[[holdings_response['holdings']['holding'] || []].flatten.map {|h| ["#{h['location']['desc']}", h['holding_id']]}]

        return {record: BibRecord.new((record.first.response unless record.has_error?)),
                holdings: holdings,
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
        return { params: params }

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

        if ['B', 'BO'].member?(user.data['cleared'])
          redirect_to "http://www.library.upenn.edu/access/ill/ill_blocked.html"
          return
        end

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

        # Populate author with contributor information from MARC record if author is not supplied
        if record['author'].presence.nil? && !params['bibid'].presence.nil?
          result = Alma::Bib.resources.almaws_v1_bibs.mms_id.get(Alma::Bib.query_merge(:mms_id => params['bibid']))
          xml = Nokogiri::XML(result.to_xml)
          author = xml.xpath('.//datafield[tag="700" or tag="710" or tag="711" or tag="720"][subfield/code="a"]/subfield/__content__/text()').to_a.join("; ");
          record['author'] = author.presence || "none specified"
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
