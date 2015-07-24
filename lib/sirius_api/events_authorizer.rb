require 'sirius_api/base_authorizer'
require 'sirius_api/umapi_client'

module SiriusApi
  class EventsAuthorizer < BaseAuthorizer
    SCOPE_PRIOTIES = [
      'read_all_events',
      'read_events_by_role',
      'read_personal_events',
      'read'
    ].map { |it| "urn:ctu:oauth:sirius.#{it}" }

    TEACHER_ROLE = 'B-00000-ZAMESTNANEC'.freeze

    scope 'read_personal_events', 'read_events_by_role', 'read_all_events' do
      permit :get, '/events'
      permit :get, '/events/personal'
      permit :get, '/events/:id'
      permit :get, '/rooms/:kos_id/events'
      permit :get, '/courses/:course_id/events'
    end

    scope 'read_personal_events' do
      permit :get, '/people/:username/events', only: ->(opts) { opts[:current_user] == opts[:target_user] }
    end

    scope 'read_events_by_role' do
      permit :get, '/people/:username/events', only: ->(opts) { authorized_by_role(opts) }
    end

    scope 'read_all_events' do
      permit :get, '/people/:username/events'
    end

    def initialize(current_user)
      super
    end

    def authorized_by_role(opts)
      current_user_id = opts[:current_user]
      target_user_id = opts[:target_user]

      current_user = umapi_client.request_user_info(current_user_id)
      return true if current_user['roles'].include?(TEACHER_ROLE)
      target_user = umapi_client.request_user_info(target_user_id)
      return target_user['roles'].include?(TEACHER_ROLE)
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
