require 'role_playing'
require 'interpipe/interactor'
require 'core_ext/then'
require 'corefines'
require 'axiom/types'
require 'virtus'

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

        # XXX: This is a hack for backward compatibility. Parameter "deleted"
        # used to be a Boolean and we added additional value "all".
        # In next version of API, "cancelled" and "deleted" should be two
        # separate parameters.
        param_deleted = coerce_param_deleted(params[:deleted])
        @deleted = param_deleted == :all
        @cancelled = @deleted || param_deleted

        @type = params[:event_type]
        @events = DateFilteredDataset.played_by(events) do |dataset|
          dataset
            .filter_by_date(**params.only(:from, :to, :with_original_date).to_h.rekey!)
            .then_if(hide_deleted?) { |q|
              # XXX: Temporary(?) hack until separate "cancelled" attribute is added.
              if hide_cancelled?
                q.where(deleted: false)
              else
                q.where('deleted IS FALSE OR deleted IS TRUE AND applied_schedule_exception_ids IS NOT NULL')
              end
            }
            .then_if(@type) { |q| q.where(event_type: @type) }
        end
      end

      def to_h
        { events: events }
      end

      protected

      # @param value [String]
      # @return [Boolean|Symbol] true, false, or :all
      def coerce_param_deleted(value)
        return false if value.nil?
        return :all if value.to_s.downcase == 'all'
        @boolean_coercer ||= Virtus::Attribute.build(Axiom::Types::Boolean)
        @boolean_coercer.coerce(value)
      end

      private

      def hide_cancelled?
        (@format == :ical) || !@cancelled
      end

      def hide_deleted?
        (@format == :ical) || !@deleted
      end

    end
  end
end
