require 'sirius_api/errors'

module SiriusApi
  Permission = Struct.new(:method, :url, :options) do
    def ==(other)
      method == other.method && url == other.url
    end
  end

  class BaseAuthorizer

    attr_reader :current_user

    class << self
      def scope(*scopes, &block)
        @current_scopes = scopes
        yield
      end

      def permit(method, url, options = {})
        @current_scopes.each do |scope|
          (scope_registry[scope] ||= []) << Permission.new(method, url, options)
        end
      end

      def scope_registry
        @scope_registry ||= {}
      end
    end

    def initialize(current_user)
      @current_user = current_user
    end

    def authorize_request!(scopes, method, url, route_params = {})
      unless check_access(scopes, method, url, route_params)
        raise SiriusApi::Errors::Authorization, "Access not permitted for #{method} #{url} with scopes=#{scopes}"
      end
    end

    def check_access(scopes, method, url, route_params)
      checked_permission = Permission.new(method, url)
      request_options = build_options(scopes, method, url, route_params)
      scopes.each do |scope|
        scope_permissions = self.class.scope_registry[scope] || []
        return true if permission_allowed?(scope_permissions, checked_permission, request_options)
      end
      false
    end

    private

    def build_options(scopes, method, url, route_params)
      {
        scopes: scopes,
        method: method,
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
      return only_block.nil? || only_block.call(request_options)
    end
  end

end
