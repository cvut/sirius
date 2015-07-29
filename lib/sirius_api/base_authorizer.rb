require 'sirius_api/errors'

module SiriusApi
  Permission = Struct.new(:http_method, :url, :options) do
    def ==(other)
      http_method == other.http_method && url == other.url
    end
  end

  class BaseAuthorizer

    attr_reader :current_user

    SCOPE_BASE = 'urn:ctu:oauth:sirius:'.freeze

    class << self
      # Sets scope(s) for access rule definitions (defined by `.permit`).
      #
      # Calling `.permit` inside given block will define new access rule
      # for all specified scopes.
      #
      # @param scopes [*String] One or more scopes for access rule definition.
      #
      def scope(*scopes, &block)
        @current_scopes = scopes.map { |it| prepend_prefix_if_missing(it, SCOPE_BASE) }
        yield
      end

      # Defines a new access rule.
      #
      # This should be only called inside the `.scope` block because a scope definition
      # is required for every rule definition.
      #
      # @param http_method [Symbol] lowercase name of http method for which is the rule defined, e.g. :get, :post ...
      # @param url [String] URL template for which is the rule defined, e.g. '/events/:id'
      # @option options [Proc] :only Proc for optionally restricting the defined access rule.
      #   If set, the access will be only allowed if the block return value is true.
      #
      def permit(http_method, url, options = {})
        @current_scopes.each do |scope|
          (scope_registry[scope] ||= []) << Permission.new(http_method, url, options)
        end
      end

      # Retrieves all rules defined by permission DSL.
      def scope_registry
        @scope_registry ||= {}
      end

      def prepend_prefix_if_missing(str, prefix)
        if str.start_with?('urn:')
          str
        else
          prefix + str
        end
      end
    end

    # Creates a new authorizer.
    #
    # @param current_user [String] Username of user currently accessing the application.
    #
    def initialize(current_user)
      @current_user = current_user
    end

    # Performs access check for a http request.
    #
    # Access check is done by searching for an access rule matching the current request.
    # The set of searched rules is limited by specified scopes. If no matching rule is found,
    # access is denied, otherwise matching rule is evaluated and access is granted / denied
    # according to rule parameters.
    #
    # @param scopes [Array] Collection scopes strings for current user / application.
    #   Scopes don't have to be prefixed by default URN prefix (will be added automatically if missing).
    # @param http_method [Symbol] Lowercase name of currently performed http method, e.g. :get, :post ...
    # @param url [String] URL template for current request, e.g. '/events/:id'
    # @param route_params [Hash] Map of route parameters and their values.
    #
    def authorize_request!(scopes, http_method, url, route_params = {})
      prefixed_scopes = scopes.map { |scope| self.class.prepend_prefix_if_missing(scope, SCOPE_BASE) }
      unless check_access(prefixed_scopes, http_method, url, route_params)
        raise SiriusApi::Errors::Authorization, "Access not permitted for #{http_method} #{url} with scopes=#{prefixed_scopes}"
      end
    end

    private

    def check_access(scopes, http_method, url, route_params)
      checked_permission = Permission.new(http_method, url)
      request_options = build_options(scopes, http_method, url, route_params)
      scopes.any? do |scope|
        scope_permissions = self.class.scope_registry[scope] || []
        permission_allowed?(scope_permissions, checked_permission, request_options)
      end
    end

    def build_options(scopes, http_method, url, route_params)
      {
        scopes: scopes,
        http_method: http_method,
        url: url,
        route_params: route_params,
        current_user: @current_user,
        target_user: route_params[:username]
      }
    end

    def permission_allowed?(scope_permissions, checked_permission, request_options)
      matching_permission = scope_permissions.find { |it| it == checked_permission }
      return false unless matching_permission
      only_block = matching_permission.options[:only]
      only_block.nil? || only_block.call(request_options)
    end
  end
end
