require 'models/schedule_exception'
require 'schedule_exceptions_representer'
require 'api_helper'

module API
  class ScheduleExceptionsEndpoints < Grape::API
    helpers ApiHelper

    resource :schedule_exceptions do
      params { use :pagination }

      get do
        represent_paginated(ScheduleException.dataset, ScheduleExceptionsRepresenter)
      end

      params do
        requires :id, type: Integer, desc: 'ID of the schedule exception'
      end
      route_param :id do
        get do
          ScheduleExceptionsRepresenter.new ::ScheduleException.with_pk!(params[:id])
        end
      end
    end
  end
end
