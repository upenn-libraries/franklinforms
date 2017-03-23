class FormController < ApplicationController
  include PostProcessor

  def view
    #begin
      render params[:id], locals: locals
    #rescue
      #render 'error'
    #end
  end

  def submit
    post_process(params[:id], locals)
    render :confirmation
  end

  def locals
    username, _ = ActionController::HttpAuthentication::Basic::user_name_and_password(request)
    record = Alma::Bib.find([params[:bibid]], {expand: :p_avail})
    {record: BibRecord.new((record.first.response unless record.has_error?)),
     user: User.new(username),
     params: params}
  end

end
