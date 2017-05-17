module PreProcessor

  def pre_process(form_id, params)
    case form_id
      when 'fixit', 'missing', 'enhanced'
        username, _ = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
        record = Alma::Bib.find([params[:bibid]], {expand: :p_avail})

        return {record: BibRecord.new((record.first.response unless record.has_error?)),
                user: User.new(username),
                params: params}
      else
        # TODO probably should email an admin here
        raise
    end
  end

end
