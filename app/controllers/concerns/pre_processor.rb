module PreProcessor
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper
  def pre_process(form_id, params)
    username = if Rails.env.development?
                 ENV['DEVELOPMENT_USERNAME']
               else
                 request.headers['HTTP_REMOTE_USER']&.split('@')&.first || ''
               end
    case form_id
      when 'fixit', 'enhanced', 'course', 'booksbymail', 'inprocess', 'onorder'
        record = Alma::Bib.get_availability([params[:bibid]], {expand: :p_avail})
        holdings = record.availability[params[:bibid]][:holdings].map do |holding|
          [holding['location'], holding['holding_id']]
        end
        return { record: BibRecord.new((record.bib_data if record.bib_data.present?)),
                 holdings: holdings,
                 user: User.new(username),
                 params: params }
      when 'missing'
        record = Alma::Bib.get_availability([params[:bibid]], {expand: :p_avail})
        holdings = record.availability[params[:bibid]][:holdings].map do |holding|
          [holding['location'], holding['holding_id']]
        end
        return { record: BibRecord.new((record.first.response unless record.has_error?)),
                 holdings: holdings,
                 user: User.new(username),
                 params: params }
      when 'aeon'
      when 'help'
        return { params: params }
      when 'resourcesharing'
        return {user: User.new(username)}
    when 'ill', 'facultyexpress'

      # Setup User or Proxy info
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
        redirect_to ill_problem_path
        return
      end

      # Compose requested record info hash
      record = Illiad.getBibData(params)

      # Populate author with contributor information from MARC record if author is not supplied
      if record['author'].presence.nil? && !params['bibid'].presence.nil?
        result = Alma::Bib.resources.almaws_v1_bibs.mms_id.get(Alma::Bib.query_merge(:mms_id => params['bibid']))
        xml = Nokogiri::XML(result.to_xml)
        author = xml.xpath('.//datafield[tag="700" or tag="710" or tag="711" or tag="720"][subfield/code="a"]/subfield/__content__/text()').to_a.join("; ");
        record['author'] = author.presence || "none specified"
      end

      # Return variables for form partial rendering
      return { record: record, user: user, params: params }
    else
      raise ArgumentError, "PreProcessor encountered un-configured form_id: #{form_id}"
    end
  end
end
