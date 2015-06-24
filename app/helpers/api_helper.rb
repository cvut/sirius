require 'corefines'
require 'sirius_api'
require 'models/person'

using Corefines::Hash[:only, :rekey]
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
    return false if user.nil?
    # FIXME: use actual role permissions, this is just a temporary workaround
    auth_scope == username || auth_scope == '*' || Person.teacher?(username) || Person.teacher?(auth_scope)
  end

  def authorize_user!(user_scope)
    unless user_allowed?(user_scope)
      raise SiriusApi::Errors::Authorization, "You don't have access to the scope for #{user_scope}."
    end
  end

  def paginate(dataset)
    dataset
      .tap { |ds| ds.opts[:total_count] = ds.count }
      .limit(params[:limit] || DEFAULT_LIMIT)
      .offset(params[:offset] || DEFAULT_OFFSET)
  end

  def represent_paginated(dataset, representer)
    paginated_dataset = paginate(dataset)
    meta = paginated_dataset.opts
      .rekey(:total_count => :count)
      .only(:count, :offset, :limit)
    representer.for_collection.new(paginated_dataset).to_hash({'meta' => meta})
  end
end
