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
        ScheduleExceptionsRepresenter.new(dataset, meta)
      end
    end

    resource :schedule_exceptions do
      get do
        represent ::ScheduleException.dataset
      end
    end
  end
end
