module PreProcessor
  include ActionView::Helpers::UrlHelper
  def pre_process(form_id, params)
    username = if Rails.env.development?
                 ENV['DEVELOPMENT_USERNAME']
               else
                 request.headers['HTTP_REMOTE_USER']&.split('@')&.first || ''
               end
    case form_id
      when 'fixit', 'enhanced', 'course', 'booksbymail', 'inprocess', 'onorder', 'booksbymail'
        record = Alma::Bib.find([params[:bibid]], {expand: :p_avail})
        holdings_response = Alma::Bib.resources.almaws_v1_bibs.mms_id_holdings.get(Alma::Bib.query_merge(mms_id: params[:bibid]));
        holdings = Hash[[holdings_response['holdings']['holding'] || []].flatten.map {|h| ["#{h['location']['desc']}", h['holding_id']]}]
        return {record: BibRecord.new((record.first.response unless record.has_error?)),
                holdings: holdings,
                user: User.new(username),
                params: params}
      when 'missing'
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
        return {user: User.new(username)}
      when 'ill', 'facultyexpress'
        # redirect to resource sharing page during ill downtime
        redirect_to '/forms/resourcesharing'
        return

        proxy_id = nil
        unless params['upennproxyid'].nil? || params['upennproxyid'].empty?
          proxy_id = params['upennproxyid']
        end
        user = User.new(username, proxy_id)
        if Rails.env.in? %w[test development]
          # populate User with whatever is needed to move things along in dev
          # eventually, TinyTDS can be fixed or eliminated and this can be removed
          user.data['proxied_for'] = username
          user.data['proxied_by'] = ''
        else
          Illiad.getIlliadUserInfo(user, params)
        end
        # Show ILL "Blocked" page if user has blocked status flags
        if user.ill_block?
          redirect_to forms_ill_problem_path
          return
        end

        record = Illiad.getBibData(params)
        delivery_method = determine_delivery_method(record, user, params)
        show_addr_msg = false
        if user.data['status'] == 'StandingFaculty'
          Illiad.getCorrectedDeptDetails(user.data)
          # TODO: should 'Book' be 'book'? See: https://github.com/upenn-libraries/discovery-app/commit/2cf7b58692b9fcab7562e6a985a3396f8a68ab07#diff-b1abebf4c8ccfb0aed18254a3efd8f8aR269
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
        raise ArgumentError, "PreProcessor encountered un-configured form_id: #{form_id}"
    end
  end

  def determine_delivery_method(record, user, params)
    if params[:deliverytype] == 'bbm'
      'Books by Mail'
    elsif record['requesttype'] == 'Book'
      "Pickup at #{user.data['illoffice_name']}"
    else
      'Web Delivery'
    end
  end
end
