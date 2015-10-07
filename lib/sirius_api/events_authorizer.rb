require 'sirius_api/base_authorizer'
require 'sirius_api/errors'
require 'sirius_api/scopes'

module SiriusApi
  class EventsAuthorizer < BaseAuthorizer

    PRIVILEGED_ROLES = Config.umapi_privileged_roles

    same_user = ->(opts) { opts[:current_user] == opts[:target_user] }

    scope Scopes::READ_PERSONAL, Scopes::READ_ROLE_BASED, Scopes::READ_ALL do
      permit :get, '/events'
      permit :get, '/events/personal'
      permit :get, '/events/:id'
      permit :get, '/rooms/:kos_id/events'
      permit :get, '/courses/:course_id/events'
    end

    scope Scopes::READ_PERSONAL do
      permit :get, '/people/:username/events', only: same_user
      permit :get, '/teachers/:username/events', only: same_user
    end

    scope Scopes::READ_ROLE_BASED do
      permit :get, '/people/:username/events', only: ->(opts) do
        authorize_by_role(opts)
      end
      permit :get, '/teachers/:username/events'
    end

    scope Scopes::READ_ALL do
      permit :get, '/people/:username/events'
      permit :get, '/teachers/:username/events'
    end

    def initialize(current_user)
      super
    end

    def authorize_by_role(opts)
      current_user_id = opts[:current_user]
      target_user_id = opts[:target_user]

      unless current_user_id
        raise SiriusApi::Errors::Authorization,
          "Access not permitted for OAuth grant Client Credentials on #{opts[:http_method].upcase} \
          #{opts[:url]}; username is required.".squeeze(' ')
      end

      # User has always acces to her personal calendar.
      return true if current_user_id == target_user_id

      # Privileged user (e.g. employee) can view all calendars.
      return true if current_user.has_any_role? PRIVILEGED_ROLES

      # Any user can view calendar of a privileged user.
      return true if User.new(target_user_id).has_any_role? PRIVILEGED_ROLES

      raise SiriusApi::Errors::Authorization,
        "Access not permitted for #{current_user} on #{opts[:http_method].upcase} #{opts[:url]}. \
        This resource requires one of IDM roles: #{PRIVILEGED_ROLES.join(', ')}, \
        or more privileged scope.".squeeze(' ')
    end
  end
end
