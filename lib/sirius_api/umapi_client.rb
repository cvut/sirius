require 'faraday'
require 'faraday_middleware'
require 'ostruct'

module SiriusApi
  class UmapiClient

    UMAPI_PEOPLE_URI = Config.umapi_people_uri

    def initialize
      client_id = Config.kosapi_oauth_client_id
      client_secret = Config.kosapi_oauth_client_secret
      base_uri = Config.umapi_base_uri
      auth_uri = Config.oauth_auth_uri
      token_uri = Config.oauth_token_uri
      @client = OAuth2::Client.new(client_id, client_secret, site: base_uri, authorize_url: auth_uri, token_url: token_uri)
    end

    def request_user_info(user_id)
      user_uri = "#{UMAPI_PEOPLE_URI}/#{user_id}"
      resp = token.get(user_uri)
      resp.parsed
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
