require 'set'
require 'interpipe/interactor'
require 'corefines/object'

require 'models/course'
require 'models/person'

module Interactors
  module Api
    class CompoundEvents
      using Corefines::Object::blank?

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
        course_ids = events.distinct.select(:course_id)
        Course.where(id: course_ids).select(:id, :name)
      end

      def teachers
        # SELECT id, full_name FROM people WHERE id IN (SELECT DISTINCT unnest(teacher_ids) FROM EVENTS)
        array_op = Sequel.pg_array(:teacher_ids)
        teacher_ids = events.select(array_op.unnest).distinct

        Person.where(id: teacher_ids).select(:id, :full_name)
      end

    end
  end
end
