require 'warden'
require 'models/person'
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
        username = Person.id_from_token(access_token)
        if username.nil?
          errors.add(:general, 'Invalid local access token.')
          return
        end
        success! User.new(username.freeze, Scopes::READ_PERSONAL)
      end
    end
  end
end

Warden::Strategies.add(:local_token, SiriusApi::Strategies::LocalToken)
