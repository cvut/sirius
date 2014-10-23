require 'grape'

module SiriusApi
  module Validators
    class Min < ::Grape::Validations::SingleOptionValidator
      def validate_param!(attr_name, params)
        unless params[attr_name].to_i > @option
          raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "must be at least #{@option}"
        end
      end
    end
  end
end
