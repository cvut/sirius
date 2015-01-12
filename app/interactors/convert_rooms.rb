require 'interpipe/interactor'

class ConvertRooms
  include Interpipe::Interactor

  def setup
    @rooms = {}
  end

  def perform(kosapi_rooms:, **options)
    kosapi_rooms.map do |room|
      convert_room(room)
    end
    @options = options
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
