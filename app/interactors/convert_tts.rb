require 'interpipe/interactor'

class ConvertTTS
  include Interpipe::Interactor

  DB_KEYS = [:day, :duration, :first_hour, :parity]

  def setup
    @rooms = {}
  end

  def perform(timetable_slots:, rooms:, **options)
    @rooms = build_rooms_hash(rooms)
    @timetable_slots = timetable_slots.map do |parallel_id, slots|
      slots.map { |slot| convert_slot(slot, parallel_id) }
    end.flatten
  end

  def results
    {
        timetable_slots: @timetable_slots
    }
  end

  private
  def build_rooms_hash(rooms)
    Hash[rooms.map{|room| [room.kos_code, room]}]
  end

  def convert_slot(slot, parallel_id)
    room_code = slot.room.link_title
    slot_hash = slot.to_hash
    slot_hash.select { |key,_| DB_KEYS.include? key }
    TimetableSlot.new(slot_hash) do |s|
      s.id = slot.id
      s.parallel_id = parallel_id
      s.room = @rooms[room_code]
    end
  end

end
