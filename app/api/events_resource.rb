require 'models/event'
require 'event_representer'
require 'api_helper'
module API
  class EventsResource < Grape::API
    helpers ApiHelper

    resource :events do

      desc 'Get all events'
      get do
        represent ::Event.all, with: EventRepresenter
      end

      params do
        requires :id, type: Integer, desc: 'ID of the event'
      end
      route_param :id do
        desc 'Get an event'
        get do
          event = Event[params[:id]]
          represent event, with: EventRepresenter
        end
      end

    end

  end
end
