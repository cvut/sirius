Sequel.migration do
  up do
    extension :pg_enum
    Sequel.extension :pg_hstore_ops
    create_enum :event_source_type, %w(manual_entry timetable_slot course_event exam teacher_timetable_slot)
    alter_table(:events) do
      add_column :source_type, :event_source_type
      add_column :source_id, String
      add_index :source_type
      add_index :source_id
    end

    # Copy data from source to source_id and source_type
    self[:events].exclude(timetable_slot_id: nil)
      .update(source_type: 'timetable_slot', source_id: :timetable_slot_id)
    self[:events].where(Sequel.hstore_op(:source).has_key?('course_event_id'))
      .update(source_type: 'course_event', source_id: Sequel.hstore_op(:source)['course_event_id'])
    self[:events].where(Sequel.hstore_op(:source).has_key?('exam_id'))
      .update(source_type: 'exam', source_id: Sequel.hstore_op(:source)['exam_id'])
    self[:events].where(Sequel.hstore_op(:source).has_key?('teacher_timetable_slot_id'))
      .update(source_type: 'teacher_timetable_slot',
      source_id: Sequel.hstore_op(:source)['teacher_timetable_slot_id'])
    self[:events].where(source_id: nil)
      .update(source_type: 'manual_entry')

    alter_table(:events) do
      add_unique_constraint [:faculty, :source_type, :source_id, :absolute_sequence_number]
    end
  end

  down do
    extension :pg_enum
    alter_table(:events) do
      drop_column :source_type
      drop_column :source_id
    end
    drop_enum :event_source_type
  end
end
