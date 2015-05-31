require 'sirius_api'
##
# Helper methods used in Grape's API endpoints.
module ApiHelper
  extend Grape::API::Helpers

  params :pagination do
    optional :limit, type: Integer, values: (1..1000)
    optional :offset, type: Integer, min: 0
  end

  def api_format
    env['api.format'].to_sym
  end

  def authenticate!
    env['warden'].authenticate!
  end

  def auth_user
    env['warden'].user
  end

  def user_allowed?(username)
    user = auth_user
    !user.nil? && ((user == username) || (user == '*'))
  end

  def authorize_user!(user_scope)
    unless user_allowed?(user_scope)
      raise SiriusApi::Errors::Authorization, "You don't have access to the scope for #{user_scope}."
    end
  end
end
