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
          fail 'Missing access token'
          return
        end
        username = Token.authenticate(access_token)
        username.nil? ? fail('Invalid access token') : success!(username.freeze)
        # token = env['HTTP_AUTH_TOKEN'] || env['rack.request.query_hash']['AUTH_TOKEN']
      end
    end
  end
end

Warden::Strategies.add(:local_token, SiriusApi::Strategies::LocalToken)
