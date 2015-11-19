require 'faraday'
require 'faraday_middleware'
require 'ostruct'
require 'corefines'

module SiriusApi
  class UmapiClient

    using Corefines::Object::in?

    SITE = Config.umapi_people_uri

    def user_has_roles?(username, roles, operator: :all)
      fail ArgumentError, "Parameter 'username' must not be blank." if username.blank?
      fail ArgumentError, "Parameter 'roles' must not be empty." if roles.nil? || roles.empty?

      unless operator.to_s.in? %(all any none)
        fail ArgumentError, "Operator must be 'all', 'any', or 'none'."
      end

      user_uri = "#{SITE}/#{username}/roles?#{operator}=#{roles.to_a.join(',')}"
      resp = send_request(:head, user_uri)

      case resp.status
      when 200 then true
      when 404 then false
      else raise "Invalid response for #{user_uri} with status #{resp.status}."
      end
    end

    private

    def token
      @token ||= (Thread.current[:umapi_token] ||= client.client_credentials.get_token)
      renew_token! if @token.expired?
      @token
    end

    def send_request(http_method, uri)
      resp = token.request(http_method, uri)
      if resp.status == 401
        renew_token!
        token.request(http_method, uri)
      else
        resp
      end
    end

    def client
      OAuth2::Client.new(
        Config.oauth_client_id,
        Config.oauth_client_secret,
        site: SITE,
        authorize_url: Config.oauth_auth_uri,
        token_url: Config.oauth_token_uri,
        raise_errors: false,
        max_redirects: 0
      )
    end

    def renew_token!
      @token = Thread.current[:umapi_token] = @token.refresh!
    end

  end
end
