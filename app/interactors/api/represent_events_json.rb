require 'interpipe/interactor'
require 'events_representer'
require 'interactors/api/paginate'
require 'interactors/api/compound_events'

module Interactors
  module Api
    class RepresentEventsJson
      include Interpipe::Interactor

      attr_reader :meta, :events, :compounds, :representer

      def perform(events:, params:)
        paginated = Paginate.perform(dataset: events, params: params)
        @meta = paginated.meta
        @events = paginated.dataset
        @compounds = CompoundEvents.perform(events: @events, params: params).compounds
        @representer = EventsRepresenter.for_collection.prepare(@events)
      end

      def to_hash(options = {})
        representer.to_hash(
          courses: compounds[:courses].to_a,
          teachers: compounds[:teachers].to_a,
          schedule_exceptions: compounds[:schedule_exceptions].to_a,
          'meta' => meta)
      end

    end
  end
end
