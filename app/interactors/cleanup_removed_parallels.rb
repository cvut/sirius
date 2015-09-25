require 'interpipe/interactor'

class CleanupRemovedParallels
  include Interpipe::Interactor

  def perform(parallels: , faculty_semester: , **options)
    @parallels = parallels
    @options = options
    seen_ids = parallels.map(&:id)
    stored_ids = Parallel.where(
      semester: faculty_semester.code,
      faculty: faculty_semester.faculty,
      deleted_at: nil
    ).select_map(:id)
    missing_ids = stored_ids - seen_ids
    Parallel.where(id: missing_ids, deleted_at: nil).update(deleted_at: Sequel.function(:NOW))
    TimetableSlot.where(parallel_id: missing_ids, deleted_at: nil).update(deleted_at: Sequel.function(:NOW))
  end

  def results
    { parallels: @parallels }.merge(@options)
  end
end
