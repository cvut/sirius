require 'models/schedule_exception'
require 'schedule_exceptions_representer'
require 'api_helper'

module API
  class ScheduleExceptionsEndpoints < Grape::API
    helpers ApiHelper

    helpers do
      def represent(dataset)
        meta = {
          count: dataset.count,
          offset: 0,
          limit: -1
        }
        ScheduleExceptionsRepresenter.for_collection.prepare(dataset)
      end
    end

    resource :schedule_exceptions do
      get do
        represent ::ScheduleException.dataset
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