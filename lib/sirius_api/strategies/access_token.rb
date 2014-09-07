require 'warden'
require 'models/token'
module SiriusApi
  module Strategies
    class AccessToken < Warden::Strategies::Base
      def valid?
        access_token
      end

      def access_token
        params['access_token']
      end

      def store?
        false
      end

      def authenticate!
        if access_token.blank?
          fail!('Missing access token')
        end
        username = Token.authenticate(params['access_token'])
        username.nil? ? fail!('Invalid access token') : success!(username.freeze)
        # token = env['HTTP_AUTH_TOKEN'] || env['rack.request.query_hash']['AUTH_TOKEN']
      end
    end
  end
end

Warden::Strategies.add(:access_token, SiriusApi::Strategies::AccessToken)
