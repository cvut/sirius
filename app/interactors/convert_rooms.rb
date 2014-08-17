require 'interpipe/interactor'

class ConvertRooms
  include Interpipe::Interactor

  def setup
    @rooms = {}
  end

  def perform(timetable_slots:, **options)
    timetable_slots.each do |parallel_id, slots|
      slots.each { |slot| convert_room(slot.room) }
    end
    @options = options
    @options[:timetable_slots] = timetable_slots
  end

  def results
    { rooms: @rooms.values }.merge(@options)
  end

  private
  def convert_room(room)
    return if !room || room.link_title == 'no-title'
    room_code = room.link_title
    @rooms[room_code] ||= Room.new(kos_code: room_code)
  end

end
