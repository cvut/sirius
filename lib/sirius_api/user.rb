require 'sirius_api/umapi_client'
require 'sirius_api/scopes'

module SiriusApi
  class User
    attr_reader :username, :scopes

    TEACHER_ROLE = Config.umapi_teacher_role

    def initialize(username = nil, scopes = [])
      @username = username
      @scopes = Scopes.new(*scopes)
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
      if scopes.include_any? Scopes::READ_LIMITED
        return has_role? TEACHER_ROLE
      end
      false
    end

    def to_s
      "User [username=#{username}, scopes=#{scopes.to_a}, roles=#{roles}]"
    end

    def roles
      @present_roles.to_a
    end

    def has_role?(role)
      return true if @present_roles.include? role
      return false if @absent_roles.include? role

      if umapi_client.user_has_roles?(username, [role])
        @present_roles << role
        true
      else
        @absent_roles << role
        false
      end
    end

    def scopes=(new_scopes)
      @scopes = Scopes.new(*new_scopes)
    end

    private

    def umapi_client
      @umapi_client ||= UmapiClient.new
    end
  end
end
