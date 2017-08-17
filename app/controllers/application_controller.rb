class ApplicationController < ActionController::Base

  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Blacklight::Base

  layout 'blacklight'

  protect_from_forgery with: :exception
  before_action :checkenv

  def checkenv
    if Rails.env.development?
      flash[:notice] = "TESTING: No emails will be sent"
    end
  end
end
