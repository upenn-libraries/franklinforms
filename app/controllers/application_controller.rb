class ApplicationController < ActionController::Base

  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller
  include Blacklight::Base

  layout 'blacklight'

  protect_from_forgery with: :exception
  before_action :authenticate

  # TODO: actually implement authentication
  def authenticate
    authenticate_or_request_with_http_basic {|user,pass|
      ['test'].include?(user)
    }
  end
end
