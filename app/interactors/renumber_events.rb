require 'interpipe/interactor'

class RenumberEvents
  include Interpipe::Interactor

  # Recalculates relative_sequence_number for all Events belonging to a faculty semester.
  #
  # Numbering is calculated so that events are grouped by course, parallel and event_type
  # and groups are then ordered by start time and numbered sequentially starting from 1.
  def perform(faculty_semester:)
    DB['with positions as (
        select
          id,
          row_number() over (partition by event_type, course_id, parallel_id order by starts_at) as position
        from events
        where deleted = false and faculty = :faculty and semester = :semester
      )
      update events
        set relative_sequence_number = p.position
      from positions p
      where p.id = events.id;', faculty: faculty_semester.faculty, semester: faculty_semester.code ].update
  end
end
