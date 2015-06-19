require 'set'
require 'interpipe/interactor'

require 'models/course'
require 'models/person'

module Interactors
  module Api
    class Paginate
      include Interpipe::Interactor

      attr_reader :limit, :offset

      DEFAULT_LIMIT = 20
      DEFAULT_OFFSET = 0

      def perform(dataset:, params: {}, **options)
        @orig_dataset = dataset
        @params = params
        @limit = params[:limit] || DEFAULT_LIMIT
        @offset = params[:offset] || DEFAULT_OFFSET
      end

      def count
        @count ||= @orig_dataset.count
      end

      def dataset
        @orig_dataset
          .limit(@limit)
          .offset(@offset)
      end

      def meta
        {
          count: count,
          limit: limit,
          offset: offset
        }
      end

      def to_h
        {
          dataset: dataset,
          count: count,
          limit: limit,
          offset: offset
        }
      end

    end
  end
end
