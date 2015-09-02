require 'faraday'
require 'faraday_middleware'
require 'ostruct'
require 'warden'

require 'sirius_api/scopes'
require 'sirius_api/user'

module SiriusApi
  module Strategies
    ##
    # Simple Warden strategy that authorizes requests with a Bearer access
    # token using a remote OAuth 2.0 authorization server.
    #
    # Note: It's implemented for proprietary Zuul OAAS Provider API that is
    # already deprecated. It should be modified after deploying a newer version
    # of Zuul OAAS on CTU.
    #
    # TODO: Implement caching!
    #
    class RemoteOAuthServer < Warden::Strategies::Base

      AUTHORIZATION_HEADERS = Rack::Auth::AbstractRequest::AUTHORIZATION_KEYS
      CHECK_TOKEN_URI = Config.oauth_check_token_uri
      REQUIRED_SCOPE_PREFIX = Config.oauth_scope_base

      def store?
        false
      end

      def authenticate!
        if access_token.blank?
          errors.add(:general, 'Missing OAuth access token.')
          return
        end

        token = request_token_info(access_token)
        if error_msg = validate_token_info(token)
          errors.add(:general, error_msg)
        else
          success! User.new(token.user_id, token.scope)
        end
      end

      def access_token
        authz_header = env.select { |key| AUTHORIZATION_HEADERS.include? key }
           .values.select { |v| v.start_with? 'Bearer ' }
           .map { |v| v.split(' ', 2).last }
           .first

        authz_header || params['access_token']
      end

      def request_token_info(token_value)
        resp = http_client.get(CHECK_TOKEN_URI, token: token_value)
        OpenStruct.new(resp.body).tap do |s|
          s.status = resp.status
        end
      end

      def validate_token_info(token)
        if token.status == 404
          "Invalid OAuth access token."
        elsif token.status != 200
          "Unable to verify OAuth access token (#{token.status})."
        elsif token.client_id.blank?
          "Invalid response from the OAuth authorization server."
        elsif !scope_valid?(token.scope)
          "Insufficient OAuth scope: #{token.scope.join(' ')}."
        elsif !flow_valid?(token)
          "Invalid OAuth Client Credentials Grant Flow for scope: '#{token.scope.join(' ')}'. (Username is required for limited scope.)"
        else
          nil
        end
      end

      def scope_valid?(scopes)
        scopes.any? { |scope| scope.start_with?(REQUIRED_SCOPE_PREFIX) }
      end

      def flow_valid?(token)
        scopes = Scopes.new(token.scope)
        if scopes.include_any? Scopes::READ_LIMITED
          return scopes.include_any?(Scopes::READ_ALL) || token.user_id
        end
        true
      end

      def http_client
        Faraday.new do |c|
          c.response :json, content_type: /\bjson$/
          c.adapter Faraday.default_adapter
        end
      end
    end
  end
end

Warden::Strategies.add(:remote_oauth_server, SiriusApi::Strategies::RemoteOAuthServer)
