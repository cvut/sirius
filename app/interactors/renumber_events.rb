require 'interpipe/interactor'

class RenumberEvents
  include Interpipe::Interactor

  # Recalculates relative_sequence_number for all Events belonging to a faculty semester.
  #
  # Numbering is calculated so that normal events are grouped by course, parallel and event_type.
  # Teacher timetable slots are grouped by event type and source because grouping for other event
  # types would not make much sense for them.
  # Groups are then ordered by start time and numbered sequentially starting from 1.
  #
  # @param [FacultySemester] faculty_semester for which then renumbering should be performed
  def perform(faculty_semester:)
    renumber_events(faculty_semester,
      %w[laboratory assessment course_event lecture exam tutorial],
      %i[event_type course_id parallel_id]
    )
    renumber_events(faculty_semester, %w[teacher_timetable_slot], %i[event_type source])
    cleanup_numbering(faculty_semester)
  end

  # Performs an actual renumbering query for specified faculty semester and event types.
  #
  # @param [FacultySemester] faculty_semester for which then renumbering should be performed
  # @param [Array<String>] event_types for which the renumbering should be done
  # @param [Array<Symbol>] partition_columns columns from events table that are used for making numbering groups
  def renumber_events(faculty_semester, event_types, partition_columns)
    DB['with positions as (
        select
          id,
          row_number() over (partition by :partition_columns order by starts_at) as position
        from events
        where deleted = false and faculty = :faculty and semester = :semester and event_type IN :event_types
      )
      update events
        set relative_sequence_number = p.position
      from positions p
      where p.id = events.id;',
      faculty: faculty_semester.faculty,
      semester: faculty_semester.code,
      partition_columns: partition_columns,
      event_types: event_types
    ].update
  end

  # Removes relative sequence numbers from deleted events as they do not give much sense anymore.
  #
  # @param [FacultySemester] faculty_semester for which the cleanup should be performed
  def cleanup_numbering(faculty_semester)
    DB['update events
         set relative_sequence_number = null
       where deleted = true
         and relative_sequence_number is not null
         and faculty = :faculty
         and semester = :semester',
      faculty: faculty_semester.faculty,
      semester: faculty_semester.code,
    ].update
  end
end
