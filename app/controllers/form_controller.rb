class FormController < ApplicationController
  include MailHelper

  def view
    #begin
      render params[:id], locals: locals
    #rescue
      #render 'error'
    #end
  end

  def submit
    send_emails_for_form(params[:id], locals)
    render :confirmation
  end

  def locals
    username, _ = ActionController::HttpAuthentication::Basic::user_name_and_password(request)

    {record: AlmaBib.getBibRecord(params[:bibid]),
     user: User.new(username),
     title: "Fix OPAC Request",
     params: params}
  end

end
