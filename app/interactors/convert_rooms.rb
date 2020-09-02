require 'interpipe/interactor'

class ConvertRooms
  include Interpipe::Interactor

  def perform(kosapi_rooms:, **options)
    @rooms = kosapi_rooms.map do |room|
      convert_room(room)
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
end
