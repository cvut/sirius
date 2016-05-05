require 'celluloid/debug'
require 'celluloid/test'
require 'actors/etl_consumer'

module ActorHelper

  def self.included(klass)
    klass.instance_eval do
      around do |ex|
        Celluloid.boot
        ex.run
        Celluloid.shutdown
      end
    end
  end

  def sample_actor_class(*include_modules)
    Class.new do
      include Celluloid
      include_modules.each do |mod|
        include mod
      end

      def process_row(row)
      end
    end
  end

  def sample_consumer_actor
    sample_actor_class(ETLConsumer).tap do |cls|
      cls.send(:define_method, :process_row) { |row| }
    end
  end

  def sample_producer_actor
    sample_actor_class(ETLProducer).tap do |cls|
      cls.send(:define_method, :produce_row_iterable) { raise StopIteration }
      cls.send(:define_method, :start!) do
        unmark_empty!
        buffer_empty
      end
    end
  end
end
