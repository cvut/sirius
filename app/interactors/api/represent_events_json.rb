require 'interpipe/interactor'
require 'events_representer'
require 'interactors/api/paginate'
require 'interactors/api/compound_events'

module Interactors
  module Api
    class RepresentEventsJson
      include Interpipe::Interactor

      attr_reader :meta, :events, :compounds, :representer

      def perform(events:, params:, student_output_permitted: true)
        paginated = Paginate.perform(dataset: events, params: params)
        @meta = paginated.meta
        @events = paginated.dataset

        @compounds = CompoundEvents.perform(events: @events, params: params).compounds
        converted_events = convert_events(@events.eager(:parallel).all, student_output_permitted)
        @representer = EventsRepresenter.for_collection.prepare(converted_events)
      end

      def to_hash(options = {})
        representer.to_hash(
          courses: compounds[:courses].to_a,
          teachers: compounds[:teachers].to_a,
          schedule_exceptions: compounds[:schedule_exceptions].to_a,
          'meta' => meta)
      end

      def convert_events(dataset, student_output_permitted)
        if student_output_permitted
          dataset
        else
          dataset.map do |evt|
            evt.tap {|e| e.student_ids = [] }
          end
        end
      end
    end
  end
end
