Sequel.migration do
  up do
    extension :pg_enum
    create_enum :event_type, %w(lecture tutorial laboratory course_event exam assessment teacher_timetable_slot)
    set_column_type :events, :event_type, :event_type, using: 'event_type::event_type'
    create_enum :parallel_type, %w(lecture tutorial laboratory)
    set_column_type :parallels, :parallel_type, :parallel_type, using: 'parallel_type::parallel_type'
  end

  down do
    extension :pg_enum
    set_column_type :events, :event_type, :text
    drop_enum :event_type
    set_column_type :parallels, :parallel_type, :text
    drop_enum :parallel_type
  end
end
