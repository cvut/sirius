module SiriusApi
  Permission = Struct.new(:method, :url, :options) do
    def ==(other)
      method == other.method && url == other.url
    end
  end

  class BaseAuthorizer

    def authorize_request!(scopes, method, url)
      raise SiriusApi::Errors::Authorization, "Access not permitted for #{method} #{url} with scopes=#{scopes}" unless check_access(scopes, method, url)
    end

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

    def check_access(scopes, method, url)
      checked_permission = Permission.new(method, url)
      request_options = build_options(scopes, method, url)
      scopes.each do |scope|
        permissions = self.class.scope_registry[scope] || []
        return true if permission_allowed?(permissions, checked_permission, request_options)
      end
      false
    end

    private
    def build_options(scopes, method, url)
      {
        scopes: scopes,
        method: method,
        url: url
      }
    end

    def permission_allowed?(permissions, checked_permission, request_options)
      matching_permission = permissions.find { |it| it == checked_permission }
      return false unless matching_permission
      only_block = matching_permission.options[:only]
      return only_block.nil? || only_block.call(request_options)
    end
  end

end
