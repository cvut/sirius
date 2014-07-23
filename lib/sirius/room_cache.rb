require 'models/room'

module Sirius
  class RoomCache

    def initialize
      @cache = {}
    end

    def find_or_create_by_kos_code(kos_code)
      room = get_from_cache(kos_code)
      unless room
        room = Room.find_or_create({kos_code: kos_code})
        store_to_cache(room)
      end
      room
    end

    private
    def get_from_cache(kos_code)
      @cache[kos_code]
    end

    def store_to_cache(room)
      @cache[room.kos_code] = room
    end

  end
end
