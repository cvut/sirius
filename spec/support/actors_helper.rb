require 'actors/etl_actor'

module ActorHelper

  def sample_actor_class
    Class.new do
      include Celluloid
      include ETLActor

      def process_row(row)
      end
    end
  end
end
