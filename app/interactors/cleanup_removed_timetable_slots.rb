require 'interpipe/interactor'
require 'interactors/cleanup_removed_records'

class CleanupRemovedTimetableSlots < CleanupRemovedRecords
  include Interpipe::Interactor

  def perform(timetable_slots: , faculty_semester: , **options)
    @slots = timetable_slots
    @options = options
    stored_slot_ids = TimetableSlot.join(Parallel.table_name, id: :parallel_id)
      .where(semester: faculty_semester.code, faculty: faculty_semester.faculty, timetable_slots__deleted_at: nil)
      .select(Sequel.lit('timetable_slots.*'))
      .select_map(:timetable_slots__id)
    cleanup_records(@slots, stored_slot_ids, TimetableSlot)
  end

  def results
    { timetable_slots: @slots }.merge(@options)
  end
end
