require 'grape'

module SiriusApi
  module Validators
    ##
    # A Grape validator for date in format `%G-%V`; an ISO 8601 week-based year
    # and a week number.
    #
    # @example How to use
    #   params { requires :week, type: String, year_cweek: true }
    #
    class YearCweek < ::Grape::Validations::Validator

      def validate_param!(attr_name, params)
        value = params[attr_name]

        unless value =~ /\A\d{4}-\d{1,2}\z/ && (Date.strptime(value, '%G-%V') rescue false)
          raise Grape::Exceptions::Validation,
            params: [@scope.full_name(attr_name)],
            message: 'must be valid ISO 8601 week-based year and week number, e.g. 2016-42'
        end
      end
    end
  end
end
