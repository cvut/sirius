require 'day'
require 'parity'
require 'models/room'

class TimetableSlot < Sequel::Model

  many_to_one :parallel
  many_to_one :room

  class << self

    DB_KEYS = [:id, :day, :duration, :first_hour, :parity]

    def from_kosapi(slot, parallel)
      slot_hash = get_attr_hash(slot)
      db_slot = update_or_create_slot(slot_hash, parallel)
      process_room(slot, db_slot)
      db_slot.save()
    end

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
      room_code = kosapi_slot.room.link_title
      unless room_code == 'no-title'
        room = Room.find_or_create(kos_code: room_code)
        db_slot.room = room
      end
    end

  end

  def parity
    Parity.from_numeric(super)
  end

  def parity=(new_parity)
    super Parity.to_numeric(new_parity)
  end

  def day
    Day.from_numeric(super)
  end

  def day=(new_day)
    super Day.to_numeric(new_day)
  end

end
