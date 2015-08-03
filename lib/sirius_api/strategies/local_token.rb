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
          errors.add(:general, 'Missing local access token.')
          return
        end
        username = Token.authenticate(access_token)
        if username.nil?
          errors.add(:general, 'Invalid local access token.')
          return
        end
        env['user.scopes'] = ( username == '*' ? ['read'] : ['personal:read'] )
        success!(username.freeze)
        # token = env['HTTP_AUTH_TOKEN'] || env['rack.request.query_hash']['AUTH_TOKEN']
      end
    end
  end
end

Warden::Strategies.add(:local_token, SiriusApi::Strategies::LocalToken)
