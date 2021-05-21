# frozen_string_literal: true

# expose some franklinforms functionality
# NOTE: these action should be restricted to internal use via deployment
# configuration
class ApiController < ApplicationController

  PENNKEY_INVALID_CHARS_REGEX = /[^a-z0-9]/.freeze

  def user_info
    pennkey = params[:id].downcase
    if valid_pennkey? pennkey
      data = PennCommunity.getUser(params[:id])
      render json: data
    else
      head :bad_request
    end
  rescue StandardError => _e
    head :internal_server_error
  end

  private

  # id _must_ be a PennKey, which i think only contains 0-9a-z
  # @param [String] pennkey
  def valid_pennkey?(pennkey)
    return false unless pennkey.present?

    return false if pennkey.match PENNKEY_INVALID_CHARS_REGEX

    true
  end
end
