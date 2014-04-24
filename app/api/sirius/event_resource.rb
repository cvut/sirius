module Sirius
  class EventResource < Grape::API
    helpers ApiHelper

    resource :events do

      desc 'Get all events'
      get do
        represent ::Event.all, with: EventRepresenter
      end


      desc 'Create an event'
      params do
        requires :name, type: String, desc: 'Name of the event'
        requires :starts_at, type: DateTime, desc: 'Start time and date of the event'
        requires :ends_at, type: DateTime, desc: 'End time and date of the event'
      end
      post do
        event = Event.create(declared(params, include_missing: false))
        # error!(present_error(:record_invalid, event.errors.full_messages)) unless <%= name.underscore %>.errors.empty?
        error!(:record_invalid, 422) unless event.errors.empty? # event.errors.full_messages)
        represent event, with: EventRepresenter
      end

      params do
        requires :id, type: Integer, desc: 'ID of the event'
      end
      route_param :id do
        desc 'Get an event'
        get do
          event = Event.find(params[:id])
          represent event, with: EventRepresenter
        end

        desc 'Update an event'
        params do
          requires :id, desc: 'ID of the event to update'
        end
        put do
          event = Event.find(params[:id])
          event.update_attributes!(declared(params, include_missing: false))
          represent event, with: EventRepresenter
        end
      end

    end

  end
end
