require 'interpipe/interactor'
require 'events_representer'
require 'interactors/api/paginate'
require 'interactors/api/compound_events'

module Interactors
  module Api
    class RepresentEventsJson
      include Interpipe::Interactor

      attr_reader :meta, :events, :compounds, :representer

      def perform(events:, params:, include_student_ids: true)
        paginated = Paginate.perform(dataset: events, params: params)
        @meta = paginated.meta
        @events = paginated.dataset

        @include_student_ids = include_student_ids
        @compounds = CompoundEvents.perform(events: @events, params: params).compounds
        @representer = EventsRepresenter.for_collection.prepare(@events.eager(:parallel).all)
      end

      def to_hash(options = {})
        representer.to_hash({
          include_student_ids: @include_student_ids,
          courses: compounds[:courses].to_a,
          teachers: compounds[:teachers].to_a,
          schedule_exceptions: compounds[:schedule_exceptions].to_a,
          'meta' => meta
        })
      end
    end
  end
end
