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

  def user_allowed?(username)
    user = auth_scope
    return false if user.nil?
    # FIXME: use actual role permissions, this is just a temporary workaround
    user == username || user == '*' || Person.teacher?(username) || Person.teacher?(user)
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
