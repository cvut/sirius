require 'interpipe/interactor'

class ConvertTTS
  include Interpipe::Interactor

  DB_KEYS = [:day, :duration, :first_hour, :start_time, :end_time]
  PARITY_VALUES = ['even', 'odd', 'both']

  def setup
    @rooms = {}
  end

  def perform(timetable_slots:, rooms:, **options)
    @rooms = build_rooms_hash(rooms)
    @options = options
    @timetable_slots = timetable_slots.map do |parallel_id, slots|
      slots.reject {|slot| not valid?(slot) }.map { |slot| convert_slot(slot, parallel_id) }
    end.flatten
  end

  def results
    {
        timetable_slots: @timetable_slots
    }.merge(@options)
  end

  private
  def build_rooms_hash(rooms)
    Hash[rooms.map{|room| [room.kos_code, room]}]
  end

  def convert_slot(slot, parallel_id)
    room_code = slot.room.link_id if slot.room
    slot_hash = slot.to_hash.select { |key, _| DB_KEYS.include? key }

    TimetableSlot.new(slot_hash) do |s|
      s.id = slot.id
      s.parity = slot.parity if slot.weeks.blank?
      s.parallel_id = parallel_id
      s.room = @rooms[room_code] if room_code
      s.deleted_at = nil
      s.weeks = parse_weeks(slot.weeks) unless slot.weeks.blank?
    end
  end

  def valid?(slot)
    slot.day &&
      (PARITY_VALUES.include?(slot.parity.to_s) || !slot.weeks.blank?) &&
      (slot.first_hour && slot.duration || slot.start_time && slot.end_time)
  end

  def parse_weeks(weeks)
    weeks.split(',').flat_map { |interval|
      if interval.include?('-')
        from, to = interval.split('-', 2)
        (Integer(from)..Integer(to)).to_a
      else
        Integer(interval)
      end
    }.sort.uniq
  end

end
