class ApplicationController < ActionController::Base

  #protect_from_forgery with: :exception
  before_action :checkenv

  def checkenv
    flash[:notice] = 'TESTING: No emails will be sent' if Rails.env.development?
  end
end
