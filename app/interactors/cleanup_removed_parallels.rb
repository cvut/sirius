require 'interpipe/interactor'
require 'interactors/cleanup_removed_records'

class CleanupRemovedParallels < CleanupRemovedRecords
  include Interpipe::Interactor

  def perform(parallels: , faculty_semester: , **options)
    @parallels = parallels
    @options = options
    stored_parallel_ids = Parallel.where(
      semester: faculty_semester.code,
      faculty: faculty_semester.faculty,
      deleted_at: nil
    ).select_map(:id)
    missing_ids = cleanup_records(parallels, stored_parallel_ids, Parallel)
    TimetableSlot.where(parallel_id: missing_ids, deleted_at: nil).update(deleted_at: Sequel.function(:NOW))
  end

  def results
    { parallels: @parallels }.merge(@options)
  end
end
