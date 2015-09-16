require 'models/event'
require 'models/room'
require 'models/person'
require 'models/course'
require 'api_helper'

require 'format_events_ical'
require 'interactors/api/filter_events'
require 'interactors/api/represent_events_json'
require 'events_representer'
require 'sirius_api/events_authorizer'

module API
  class EventsEndpoints < Grape::API
    using Corefines::Object::then

    helpers ApiHelper

    # represent Event, with: EventsRepresenter
    helpers do
      def represent(dataset)
        filtered = Interactors::Api::FilterEvents.perform(events: dataset, params: params, format: api_format)
        case api_format #XXX this is not great, it should be handled by Grape formatters
        when :jsonapi
          Interactors::Api::RepresentEventsJson.perform(
            events: filtered.events,
            params: params,
            student_output_permitted: current_user.student_access_allowed?
          ).to_hash
        when :ical
          FormatEventsIcal.perform(events: filtered.events)
        else
          raise "Unknown output format '#{api_format}'"
        end
      end

      params :date_filter do
        optional :from, type: DateTime
        optional :to, type: DateTime
        optional :with_original_date, type: Boolean, default: false
      end
      params :deleted do
        optional :deleted, type: Boolean, default: false
      end
      params :event_type do
        optional :event_type, type: String, values: %w{assessment course_event exam laboratory lecture tutorial}
      end
      params :filter_events do
        use :pagination
        use :date_filter
        use :deleted
        use :event_type
      end
      # FIXME: This should be coerced to Set with predefined allowed tokens
      params :compound do
        optional :include, type: String, regexp: /\A[a-z,_]+\z/
      end
    end

    before do
      authenticate!
      authorize!(SiriusApi::EventsAuthorizer)
    end

    resource :events do

      desc 'Get all events'
      params do
        use :filter_events
        use :compound
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
          EventsRepresenter.new ::Event.with_pk!(params[:id])
        end
      end

    end

    desc 'Filter events by room'
    segment :rooms do
      params do
        requires :kos_id, type: String, desc: 'Common room identification used by KOS'
        use :filter_events
        use :compound
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
        use :compound
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
        use :filter_events
        use :compound
      end
      route_param :course_id, requirements: { course_id: /[a-z0-9\.\-\:]+/i } do
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
