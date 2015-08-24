require 'warden'
require 'models/token'
require 'sirius_api/user'

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
        scopes = ( username == '*' ? Scopes::READ_ALL : Scopes::READ_PERSONAL )
        success! User.new(username.freeze, scopes)
      end
    end
  end
end

Warden::Strategies.add(:local_token, SiriusApi::Strategies::LocalToken)
