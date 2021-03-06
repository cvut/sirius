require 'corefines'
require 'interactors/api/paginate'
require 'models/person'
require 'sirius_api'

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

  params :date_range do
    optional :from, type: Date, default: Date.today
    optional :to, type: Date, default: Date.today + 7
  end

  params :username do
    requires :username, type: String, regexp: /\A[a-z0-9]+\z/i, desc: "person's username"
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
  def current_user
    env['warden'].user
  end

  def authorize!(auth_class)
    # Hash with route parameter values plus :route_info from Grape.
    route_params = env['rack.routing_args']
    route_method = route.route_method.downcase.to_sym
    # Matching URL template from Grape for current request, e.g. '/rooms/:kos_id/events'.
    uri = route_params[:route_info].route_namespace
    # Hash with route parameter values for matching route, e.g. { kos_id: 'T9:105' }.
    params = route_params.except(:route_info)
    auth_class.new(current_user).authorize_request!(route_method, uri, params)
  end

  def represent_paginated(dataset, representer)
    paginated = Interactors::Api::Paginate.perform(dataset: dataset, params: params)
    representer
      .for_collection
      .new(paginated.dataset.all)
      .to_hash('meta' => paginated.meta)
  end

  def not_found!
    error!({message: 'Resource not found'}, 404)
  end
end
