require 'corefines'
require 'interactors/api/paginate'
require 'models/person'
require 'sirius_api'
require 'sirius_api/events_authorizer'

using Corefines::Hash[:only, :rekey, :symbolize_keys]

##
# Helper methods used in Grape's API endpoints.
module ApiHelper
  extend Grape::API::Helpers

  DEFAULT_LIMIT = 20
  DEFAULT_OFFSET = 0

  params :pagination do
    optional :limit, type: Integer, values: (1..1000), default: DEFAULT_LIMIT
    optional :offset, type: Integer, min: 0, default: DEFAULT_OFFSET
  end

  def params_h
    params.to_h.symbolize_keys
  end

  def api_format
    env['api.format'].to_sym
  end

  def authenticate!
    env['warden'].authenticate!
  end

  # Scope of authenticated user derived from access token
  #
  # @return [String, nil] `nil` if no user was authenticated,
  #                       `'*'` if user has unlimited access to all resources,
  #                       otherwise username of authenticated user
  def auth_scope
    env['warden'].user
  end

  # Checks permissions of authenticated user to access data for a given user.
  # Based on permissions of authenticated user, user will be allowed if:
  # - The authenticated user is the same for which we request data.
  # - The authenticated user has unlimited permissions (`auth_scope` is `*`)
  # - The authenticated user is a teacher (currently same as having unlimited permissions)
  # - The person we request data for is a teacher
  #
  # Users without authentication won't be allowed.
  #
  # @param [String] username for which to check access to data
  # @return [Boolean] `true` if authenticated user is allowed to access, `false` otherwise
  # @todo Move this to a separate interactor or something, this is starting to get complicated
  def user_allowed?(username)
    return false if auth_scope.nil?
    # FIXME: use actual role permissions, this is just a temporary workaround
    auth_scope == username || auth_scope == '*' || Person.teacher?(username) || Person.teacher?(auth_scope)
  end

  def authorize_user!(user_scope)
    unless user_allowed?(user_scope)
      raise SiriusApi::Errors::Authorization, "You don't have access to the scope for #{user_scope}."
    end
  end

  def authorize!
    route_params = env['rack.routing_args']
    scopes = env['user.scopes'] || []
    SiriusApi::EventsAuthorizer.new(env['warden'].user)
      .authorize_request!(scopes, route.route_method.downcase.to_sym, route_params[:route_info].route_namespace, route_params.except(:route_info))
  end

  def represent_paginated(dataset, representer)
    paginated = Interactors::Api::Paginate.perform(dataset: dataset, params: params)
    representer
      .for_collection
      .new(paginated.dataset)
      .to_hash('meta' => paginated.meta)
  end
end
