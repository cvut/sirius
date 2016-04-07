require 'celluloid/test'
require 'actors/etl_actor'

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

  def sample_actor_class
    Class.new do
      include Celluloid
      include ETLActor

      def process_row(row)
      end
    end
  end
end
