require 'sirius_api/base_authorizer'
require 'sirius_api/umapi_client'

module SiriusApi
  class EventsAuthorizer < BaseAuthorizer

    TEACHER_ROLE = Config.umapi_teacher_role

    scope 'personal:read', 'limited-by-idm:read', 'read', 'urn:ctu:oauth:sirius.read' do
      permit :get, '/events'
      permit :get, '/events/personal'
      permit :get, '/events/:id'
      permit :get, '/rooms/:kos_id/events'
      permit :get, '/courses/:course_id/events'
    end

    scope 'personal:read' do
      permit :get, '/people/:username/events', only: ->(opts) { opts[:current_user] == opts[:target_user] }
    end

    scope 'limited-by-idm:read', 'urn:ctu:oauth:sirius.read' do
      permit :get, '/people/:username/events', only: ->(opts) { authorize_by_role(opts) }
    end

    scope 'read' do
      permit :get, '/people/:username/events'
    end

    def initialize(current_user)
      super
    end

    def authorize_by_role(opts)
      current_user_id = opts[:current_user]
      target_user_id = opts[:target_user]

      return true if umapi_client.user_has_roles?(current_user_id, [TEACHER_ROLE])
      umapi_client.user_has_roles?(target_user_id, [TEACHER_ROLE])
    end

    def allow_students_output?
      true
    end

    private

    def umapi_client
      @umapi_client ||= UmapiClient.new
    end
  end
end
