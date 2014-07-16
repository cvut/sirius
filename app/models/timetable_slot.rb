require 'day'
require 'parity'

class TimetableSlot < Sequel::Model

  DB_KEYS = [:id, :day, :duration, :first_hour, :parity]

  many_to_one :parallel
  many_to_one :room

  def self.from_kosapi(slot, parallel)
    TimetableSlot.unrestrict_primary_key
    slot_hash = slot.to_hash
    slot_hash = slot_hash.select { |key,_| DB_KEYS.include? key }
    db_slot = TimetableSlot.new(slot_hash)
    db_slot.parallel_id = parallel[:id]
    room_code = slot.room.title
    db_slot.save()
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
