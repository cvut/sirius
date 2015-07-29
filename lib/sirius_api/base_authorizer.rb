require 'sirius_api/errors'

module SiriusApi
  Permission = Struct.new(:http_method, :url, :options) do
    def ==(other)
      http_method == other.http_method && url == other.url
    end
  end

  class BaseAuthorizer

    attr_reader :current_user

    SCOPE_BASE = 'urn:ctu:oauth:sirius.'.freeze

    class << self
      def scope(*scopes, &block)
        @current_scopes = scopes.map { |it| SCOPE_BASE + it }
        yield
      end

      def permit(http_method, url, options = {})
        @current_scopes.each do |scope|
          (scope_registry[scope] ||= []) << Permission.new(http_method, url, options)
        end
      end

      def scope_registry
        @scope_registry ||= {}
      end
    end

    def initialize(current_user)
      @current_user = current_user
    end

    def authorize_request!(scopes, http_method, url, route_params = {})
      prefixed_scopes = scopes.map { |scope| prepend_prefix_if_missing(scope, SCOPE_BASE) }
      unless check_access(prefixed_scopes, http_method, url, route_params)
        raise SiriusApi::Errors::Authorization, "Access not permitted for #{http_method} #{url} with scopes=#{prefixed_scopes}"
      end
    end

    def check_access(scopes, http_method, url, route_params)
      checked_permission = Permission.new(http_method, url)
      request_options = build_options(scopes, http_method, url, route_params)
      scopes.any? do |scope|
        scope_permissions = self.class.scope_registry[scope] || []
        permission_allowed?(scope_permissions, checked_permission, request_options)
      end
    end

    private

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

    def prepend_prefix_if_missing(str, prefix)
      if str.start_with?(prefix)
        str
      else
        prefix + str
      end
    end
  end
end
