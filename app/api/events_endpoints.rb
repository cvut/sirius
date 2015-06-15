require 'models/event'
require 'models/room'
require 'models/person'
require 'models/course'
require 'event_representer'
require 'api_helper'
require 'filter_events'
require 'format_events_ical'
module API
  class EventsEndpoints < Grape::API
    helpers ApiHelper

    # represent Event, with: EventsRepresenter
    helpers do
      def represent(dataset)
        result = FilterEvents.perform(events: dataset, params: params, format: api_format).to_h
        case api_format #XXX this is not great, it should be handled by Grape formatters
        when :jsonapi
          represent_paginated(result[:events], EventRepresenter)
        when :ical
          FormatEventsIcal.perform(events: result[:events])
        else
          raise "Unknown output format '#{api_format}'"
        end
      end

      params :date_filter do
        optional :from, type: DateTime
        optional :to, type: DateTime
      end
      params :deleted do
        optional :deleted, type: Boolean, default: false
      end
      params :event_type do
        optional :event_type, type: String, values: %w{exam laboratory lecture tutorial}
      end
      params :filter_events do
        use :pagination
        use :date_filter
        use :deleted
        use :event_type
      end
    end

    before do
      authenticate!
    end

    resource :events do

      desc 'Get all events'
      params do
        use :filter_events
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
          EventRepresenter.new ::Event.with_pk!(params[:id])
        end
      end

    end

    desc 'Filter events by room'
    segment :rooms do
      params do
        requires :kos_id, type: String, desc: 'Common room identification used by KOS'
        use :filter_events
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
        use :filter_events
      end
      route_param :username do
        before do
          authorize_user! params[:username]
        end
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
        use :filter_events
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
