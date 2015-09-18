require 'sirius_api/base_authorizer'
require 'sirius_api/scopes'
require 'sirius_api/errors'

module SiriusApi
  class PeopleAuthorizer < BaseAuthorizer

    scope Scopes::READ_PERSONAL, Scopes::READ_LIMITED do
      permit :get, '/people/:username', only: ->(opts) { opts[:current_user] == opts[:target_user] }
    end

    scope Scopes::READ_ALL do
      permit :get, '/people'
      permit :get, '/people/:username'
    end

    def initialize(current_user)
      super
    end

  end
end
