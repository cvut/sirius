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

      # TODO: Implement people list with proper authorisation
      # get do
      # end

      route_param :username do
        params { use :username }
        get do
          PeopleRepresenter.new ::Person.with_pk!(params[:username])
        end
      end
    end
  end
end
