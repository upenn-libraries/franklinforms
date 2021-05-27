# frozen_string_literal: true

# expose some franklinforms functionality
# NOTE: these action should be restricted to internal use via deployment
# configuration and X-User-Token header value
class ApiController < ApplicationController

  PENNKEY_INVALID_CHARS_REGEX = /[^a-z0-9]/.freeze

  before_action :validate_header_token

  def user_info
    pennkey = params[:id].downcase
    if invalid_pennkey?(pennkey)
      head :bad_request
    else
      if ENV.fetch('ENABLE_USERINFO_ENDPOINT', false) # TODO: temp
        data = PennCommunity.getUser(params[:id])
        render json: data
      else
        head :ok
      end
    end
  rescue StandardError => e
    Honeybadger.notify e
    head :internal_server_error
  end

  private

  # id _must_ be a PennKey, which i think only contains 0-9a-z
  # @param [String] pennkey
  def invalid_pennkey?(pennkey)
    return true unless pennkey.present?

    return true if pennkey.match PENNKEY_INVALID_CHARS_REGEX

    false
  end

  # returns a 401 Unauthorized unless X-User-Token value is set and
  # matches value set in ENV
  # @raise
  # @return [TrueClass, FalseClass]
  def validate_header_token
    if request.headers['X-User-Token'] &&
       ActiveSupport::SecurityUtils.secure_compare(
         request.headers['X-User-Token'],
         ENV.fetch('USER_API_ACCESS_TOKEN')
       )
      true
    else
      head :unauthorized
      false
    end
  end
end
