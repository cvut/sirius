require 'interpipe/interactor'

class ConvertRooms
  include Interpipe::Interactor

  def perform(kosapi_rooms:, **options)
    @rooms = []
    kosapi_rooms.each do |room|
      converted_room = convert_room(room)

      unless converted_room.nil?
        @rooms << converted_room
      end
    end

    @options = options
  end

  def results
    { rooms: @rooms }.merge(@options)
  end

  private
  def convert_room(room)
    return if room.link_title == 'no-title'
    room_code = room.link_id
    Room.new(kos_code: room_code)
  end

  def extract_rooms(fetched_data)
    {}.tap do |rooms|
      fetched_data.lazy.map(&:room).reject(&:nil?).each do |room|
        rooms[room.link_id] ||= room
      end
    end.values
  end

end
