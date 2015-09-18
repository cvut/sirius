require 'sirius_api/base_authorizer'

module SiriusApi
  class EventsAuthorizer < BaseAuthorizer

    TEACHER_ROLE = Config.umapi_teacher_role

    scope Scopes::READ_PERSONAL, Scopes::READ_LIMITED, Scopes::READ_ALL do
      permit :get, '/events'
      permit :get, '/events/personal'
      permit :get, '/events/:id'
      permit :get, '/rooms/:kos_id/events'
      permit :get, '/courses/:course_id/events'
    end

    scope Scopes::READ_PERSONAL do
      permit :get, '/people/:username/events', only: ->(opts) { opts[:current_user] == opts[:target_user] }
    end

    scope Scopes::READ_LIMITED do
      permit :get, '/people/:username/events', only: ->(opts) { authorize_by_role(opts) }
    end

    scope Scopes::READ_ALL do
      permit :get, '/people/:username/events'
    end

    def initialize(current_user)
      super
    end

    def authorize_by_role(opts)
      current_user_id = opts[:current_user]
      target_user_id = opts[:target_user]
      unless current_user_id
        raise SiriusApi::Errors::Authorization, "Access not permitted for Client Credentials Grant Flow on #{opts[:http_method]} #{opts[:url]} with #{current_user}. (Username is required.)"
      end

      # User has always acces to personal calendar
      return true if current_user_id == target_user_id

      return true if current_user.has_role?(TEACHER_ROLE)
      return true if User.new(target_user_id).has_role?(TEACHER_ROLE)
      raise SiriusApi::Errors::Authorization, "Access not permitted on #{opts[:http_method]} #{opts[:url]} with #{current_user}. (#{TEACHER_ROLE} role is required for current user, URL and scope.)"
    end

  end
end
