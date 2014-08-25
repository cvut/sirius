require 'models/event'
require 'models/room'
require 'models/person'
require 'models/course'
require 'events_representer'
require 'api_helper'
require 'filter_events'
module API
  class EventsEndpoints < Grape::API
    helpers ApiHelper

    # represent Event, with: EventsRepresenter
    helpers do
      def represent(dataset)
        result = FilterEvents.perform(events: dataset, params: params, format: api_format).to_h
        EventsRepresenter.new(result.delete(:events), result)
      end

      params :pagination do
        optional :limit, type: Integer
        optional :offset, type: Integer
      end
      params :date_filter do
        optional :from, type: DateTime
        optional :to, type: DateTime
      end
    end

    resource :events do

      desc 'Get all events'
      params do
        use :pagination
        use :date_filter
      end
      get do
        represent ::Event.dataset
      end

      params do
        requires :id, type: Integer, desc: 'ID of the event'
      end
      route_param :id do
        desc 'Get an event'
        get do
          EventsRepresenter.new ::Event.with_pk!(params[:id]), singular: true
        end
      end

    end

    desc 'Filter events by room'
    segment :rooms do
      params do
        requires :kos_id, type: String, desc: 'Common room identification used by KOS'
        use :pagination
        use :date_filter
      end
      route_param :kos_id do
        resource :events do
          get do
            represent ::Room.with_code!(params[:kos_id]).events_dataset
          end
        end
      end
    end

    desc 'Filter events by person'
    segment :people do
      params do
        requires :username, type: String, regexp: /\A[a-z0-9]+\z/i, desc: '8-char unique username'
        use :pagination
        use :date_filter
      end
      route_param :username do
        resource :events do
          get do
            #XXX check if user exists; ugly!
            ::Person.with_pk!(params[:username])
            represent Event.with_person(params[:username])
          end
        end
      end
    end

    desc 'Filter events by course'
    segment :courses do
      params do
        requires :course_id, type: String, desc: 'Course identification code (faculty-specific)'
        use :pagination
        use :date_filter
      end
      route_param :course_id do
        resource :events do
          get do
            #XXX join is not necessary here (but let's planner handle this)
            represent ::Course.with_pk!(params[:course_id]).events_dataset
          end
        end
      end
    end
  end
end
