require 'faraday'
require 'faraday_middleware'
require 'ostruct'
require 'corefines'

module SiriusApi
  class UmapiClient

    using Corefines::Object::in?

    def initialize
      @client = OAuth2::Client.new(
        Config.oauth_client_id,
        Config.oauth_client_secret,
        site: Config.umapi_people_uri,
        authorize_url: Config.oauth_auth_uri,
        token_url: Config.oauth_token_uri,
        raise_errors: false
      )
    end

    def user_has_roles?(username, roles, operator: :all)
      fail ArgumentError, "Parameter 'username' must not be blank." if username.blank?
      fail ArgumentError, "Parameter 'roles' must not be empty." if roles.nil? || roles.empty?

      unless operator.to_s.in? %(all any none)
        fail ArgumentError, "Operator must be 'all', 'any', or 'none'."
      end

      user_uri = "#{@client.site}/#{username}/roles?#{operator}=#{roles.join(',')}"
      resp = token.request(:head, user_uri)

      case resp.status
      when 200 then true
      when 404 then false
      else raise "Invalid response for #{@client.site}/#{user_uri} with status #{resp.status}."
      end
    end

    private

    def token
      if @token.nil? || @token.expired?
        @token = @client.client_credentials.get_token
      end
      @token
    end
  end
end
