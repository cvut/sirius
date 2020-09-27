require 'interpipe/interactor'

class ConvertRooms
  include Interpipe::Interactor

  def perform(kosapi_rooms:, **options)
    @rooms = @rooms = kosapi_rooms.reduce([]) do |rooms, room|
      next rooms if room.link_title == 'no-title'
      rooms << Room.new(kos_code: room.link_id)
    end
    @options = options
  end

  def results
    { rooms: @rooms }.merge(@options)
  end

end
