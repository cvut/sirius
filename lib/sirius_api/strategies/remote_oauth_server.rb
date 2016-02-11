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
    # TODO: Implement caching!
    #
    class RemoteOAuthServer < Warden::Strategies::Base

      AUTHORIZATION_HEADERS = Rack::Auth::AbstractRequest::AUTHORIZATION_KEYS
      CHECK_TOKEN_URI = Config.oauth_check_token_uri

      def store?
        false
      end

      def authenticate!
        if access_token.blank?
          errors.add(:general, 'Missing OAuth access token.')
          return
        end

        token = request_token_info(access_token)
        if error_msg = validate_token(token)
          errors.add(:general, "[OAuth] #{error_msg}")
        else
          success! User.new(token.user_name, token.scope)
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
        resp = http_client.post(CHECK_TOKEN_URI, token: token_value)
        if resp.body.is_a?(Hash)
          body = resp.body
        else
          error_body = resp.body
        end
        OpenStruct.new(body || {}).tap do |s|
          s.status = resp.status
          s.error_body = error_body
        end
      end

      def validate_token(token)
        if token.status == 400
          "Invalid access token."
        elsif token.status != 200
          "Unable to verify access token (status: #{token.status}).".tap do |msg|
            Raven.capture_message(msg, token: token)
          end
        elsif token.client_id.blank? || token.exp.blank?
          "Invalid response from the authorization server.".tap do |msg|
            Raven.capture_message(msg, token: token)
          end
        elsif Time.at(token.exp) < Time.now
          "Access token has expired."
        elsif token.scope.empty?
          "Access token has no scopes granted."
        else
          nil
        end
      end

      def http_client
        Faraday.new do |c|
          c.request :url_encoded
          c.response :json, content_type: /\bjson$/
          c.adapter Faraday.default_adapter
        end
      end
    end
  end
end

Warden::Strategies.add(:remote_oauth_server, SiriusApi::Strategies::RemoteOAuthServer)
