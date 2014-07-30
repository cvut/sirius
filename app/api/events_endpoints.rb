require 'models/event'
require 'models/room'
require 'events_representer'
require 'api_helper'
require 'events_filtering'
module API
  class EventsEndpoints < Grape::API
    helpers ApiHelper

    represent Event, with: EventsRepresenter

    resource :events do

      desc 'Get all events'
      params do
        optional :limit, type: Integer
        optional :offset, type: Integer
      end
      get do
        events = EventsFiltering.new(::Event.dataset)
        represent events.call(params: params, format: api_format)
      end

      params do
        requires :id, type: Integer, desc: 'ID of the event'
      end
      route_param :id do
        desc 'Get an event'
        get do
          event = ::Event.with_pk!(params[:id])
          represent event
        end
      end

    end

    desc 'Filter events by room'
    segment :rooms do
      params do
        requires :kos_id, type: String, desc: 'Common room identification used by KOS'
      end
      route_param :kos_id do
        resource :events do
          get do
            events = ::Room.with_code!(params[:kos_id]).events_dataset
            represent EventsFiltering.new(events).call(params: params, format: api_format)
          end
        end
      end
    end

    desc 'Filter events by person'
    segment :people do
      params do
        requires :username, type: String, regexp: /\A[a-z0-9]{8}\z/i, desc: '8-char unique username'
      end
      route_param :username do
        resource :events do
          get do
          end
        end
      end
    end

    desc 'Filter events by course'
    segment :courses do
      params do
        requires :course_code, type: String, desc: 'Course identification code (faculty-specific)'
      end
      route_param :course_code do
        resource :events do
          get do
          end
        end
      end
    end
  end
end
