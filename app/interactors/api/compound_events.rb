require 'set'
require 'interpipe/interactor'
require 'corefines/object'
require 'sequel/extensions/core_refinements'

require 'models/course'
require 'models/person'

module Interactors
  module Api
    class CompoundEvents
      using Corefines::Object::blank?
      using Sequel::CoreRefinements

      include Interpipe::Interactor

      ALLOWED_JOINS = ['teachers', 'courses'].to_set.freeze

      attr_reader :events, :params

      def perform(events:, params: {})
        @events = events
        @params = params
        @joins = joins(params[:include])
      end

      def compounds
        @joins.map { |name| [name.to_sym, self.send(name)] }.to_h
      end

      # FIXME: invalid params will be silently ignored
      def joins(param)
        return Set.new if param.blank?
        compounds = param.split(',')
        ALLOWED_JOINS.intersection(compounds)
      end

      def courses
        # SELECT id, name FROM courses
        # WHERE id IN (SELECT course_id FROM events WHERE ...)
        course_ids = events.select(:course_id)
        Course.where(id: course_ids).select(:id, :name)
      end

      def teachers
        # SELECT id, full_name FROM people
        # WHERE id IN (SELECT unnest(teacher_ids) FROM events WHERE ...)
        teacher_ids = events.select(:teacher_ids.pg_array.unnest)
        Person.where(id: teacher_ids).select(:id, :full_name)
      end

    end
  end
end
