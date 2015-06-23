require 'role_playing'
require 'interpipe/interactor'
require 'core_ext/then'
require 'corefines'

require 'date_filtered_dataset'

module Interactors
  module Api
    ##
    # Filters events by page (offset, limit)
    # also depending on a requested format.
    class FilterEvents
      include RolePlaying::Context
      include Interpipe::Interactor
      using Corefines::Hash[:only, :rekey]

      attr_reader :events

      def perform(events: , params: {}, format: :jsonapi)
        @format = format
        @deleted = params[:deleted] || false
        @type = params[:event_type]
        @events = DateFilteredDataset.played_by(events) do |dataset|
          dataset
            .filter_by_date(**params.only(:from, :to, :with_original_date).to_h.rekey!)
            .then_if(hide_deleted?) { |q| q.where(deleted: false) }
            .then_if(@type) { |q| q.where(event_type: @type) }
        end
      end

      def to_h
        { events: events }
      end

      private

      def hide_deleted?
        (@format == :ical) || !@deleted
      end
    end
  end
end
