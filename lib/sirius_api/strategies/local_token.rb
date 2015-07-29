require 'warden'
require 'models/token'

module SiriusApi
  module Strategies
    class LocalToken < Warden::Strategies::Base

      def access_token
        params['access_token']
      end

      def store?
        false
      end

      def authenticate!
        if access_token.blank?
          return 'Missing access token'
        end
        username = Token.authenticate(access_token)
        if username.nil?
          return 'Invalid access token'
        end
        env['user.scopes'] = ['read_personal_events']
        success!(username.freeze)
        # token = env['HTTP_AUTH_TOKEN'] || env['rack.request.query_hash']['AUTH_TOKEN']
      end
    end
  end
end

Warden::Strategies.add(:local_token, SiriusApi::Strategies::LocalToken)
