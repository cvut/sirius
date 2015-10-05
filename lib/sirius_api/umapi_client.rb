require 'faraday'
require 'faraday_middleware'
require 'ostruct'
require 'corefines'

module SiriusApi
  class UmapiClient

    using Corefines::Hash::rekey

    UMAPI_PEOPLE_URI = Config.umapi_people_uri

    def initialize
      client_id = Config.kosapi_oauth_client_id
      client_secret = Config.kosapi_oauth_client_secret
      auth_uri = Config.oauth_auth_uri
      token_uri = Config.oauth_token_uri
      @client = OAuth2::Client.new(
        client_id,
        client_secret,
        site: UMAPI_PEOPLE_URI,
        authorize_url: auth_uri,
        token_url: token_uri,
        raise_errors: false
      )
    end

    def user_has_roles?(username, roles, operator: 'all')
      roles_param = roles.join(',')
      user_uri = "#{UMAPI_PEOPLE_URI}/#{username}/roles?#{operator}=#{roles_param}"
      resp = token.request(:head, user_uri)

      return true if resp.status == 200
      return false if resp.status == 404
      raise "Invalid response for #{user_uri} with status #{resp.status}."
    end

    private

    def token
      authenticate if !@token || @token.expired?
      @token
    end

    def authenticate
      @token = @client.client_credentials.get_token
    end
  end
end
