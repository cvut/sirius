require 'role_playing'
require 'models/event'

class PlannedParallel < RolePlaying::Role

  def renumber_events
    events = Event.where(parallel_id: id, deleted: false).order(:starts_at).all
    relative_seq = 0
    events.each do |evt|
      evt.relative_sequence_number = relative_seq += 1
      evt.save
    end
  end

end
