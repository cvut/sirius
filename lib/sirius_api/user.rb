require 'sirius_api/umapi_client'
require 'sirius_api/scopes'

module SiriusApi
  # TODO: This class should be renamed! This name doesn't make sense, because "user" may be
  #       a client application itself with no associated user (OAuth grant client credentials).
  class User
    attr_reader :username, :scopes

    PRIVILEGED_ROLES = Config.umapi_privileged_roles

    def initialize(username = nil, scopes = [], umapi_client: UmapiClient.new)
      @username = username
      @scopes = Scopes.new(*scopes)
      @umapi_client = umapi_client
      @present_roles = Set.new
      @absent_roles = Set.new
    end

    # Checks whether access to students (associated with an event) is allowed for current user.
    #
    # Scope 'read' always permits student access.
    # Scope 'limited-by-idm' depends on current user role.
    # Any other scopes (e.g. 'personal:read') are disallowed to view students.
    #
    def student_access_allowed?
      return true if scopes.include? Scopes::READ_ALL
      if username && scopes.include_any?(Scopes::READ_LIMITED)
        return has_any_role? PRIVILEGED_ROLES
      end
      false
    end

    def to_s
      "User [username=#{username}, scopes=#{scopes.to_a.join(' ')}, roles=#{roles.join(' ')}]"
    end

    def roles
      @present_roles.to_a
    end

    def has_any_role?(*roles)
      fail 'Cannot check roles without username.' unless username

      roles = Set.new(roles)

      return true if @present_roles.intersect? roles
      return false if @absent_roles.intersect? roles

      if @umapi_client.user_has_roles?(username, roles, operator: :any)
        @present_roles.merge(roles)
        true
      else
        @absent_roles.merge(roles)
        false
      end
    end

    def scopes=(new_scopes)
      @scopes = Scopes.new(*new_scopes)
    end
  end
end
