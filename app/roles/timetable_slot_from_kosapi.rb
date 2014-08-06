require 'role_playing'

class TimetableSlotFromKOSapi < RolePlaying::Role

  class << self

    DB_KEYS = [:id, :day, :duration, :first_hour, :parity]

    def from_kosapi(slot, parallel)
      slot_hash = get_attr_hash(slot)
      db_slot = update_or_create_slot(slot_hash, parallel)
      process_room(slot, db_slot)
      db_slot.save()
    end

    private
    def get_attr_hash(slot)
      slot_hash = slot.to_hash
      slot_hash.select { |key,_| DB_KEYS.include? key }
    end

    def update_or_create_slot(slot_hash, parallel)
      TimetableSlot.unrestrict_primary_key
      db_slot = TimetableSlot[slot_hash[:id]]
      if db_slot
        db_slot.set(slot_hash)
      else
        db_slot = TimetableSlot.new(slot_hash)
      end
      db_slot.parallel_id = parallel.link.link_id
      db_slot
    end

    def process_room(kosapi_slot, db_slot)
      return if !kosapi_slot.room || kosapi_slot.room.link_title == 'no-title'
      room_code = kosapi_slot.room.link_title
      room = Room.find_or_create(kos_code: room_code)
      db_slot.room = room
    end

  end

end
