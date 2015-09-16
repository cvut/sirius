require 'models/faculty_semester'
require 'api_helper'
require 'people_representer'
require 'sirius_api/people_authorizer'

module API
  class PeopleEndpoints < Grape::API
    helpers ApiHelper

    before do
      authenticate!
      authorize!(SiriusApi::PeopleAuthorizer)
    end

    resource :people do
      params { use :pagination }

      get do
        # TODO: Implement people list with proper authorisation
      end

      params do
        requires :username, type: String, regexp: /\A[a-z0-9]+\z/i, desc: '8-char unique username'
      end
      route_param :username do
        get do
          PeopleRepresenter.new ::Person.with_pk!(params[:username])
        end
      end
    end
  end
end
