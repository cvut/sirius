Sequel.migration do
  change do
    alter_table :events do
      add_column :teacher_ids, 'varchar(50)[]'
      add_column :student_ids, 'varchar(50)[]'
      add_column :relative_sequence_number, Integer
      add_column :deleted, TrueClass
      add_column :event_type, String

      add_foreign_key :parallel_id, :parallels
      add_foreign_key :timetable_slot_id, :timetable_slots

      rename_column :sequence_number, :absolute_sequence_number

      add_index :teacher_ids
      add_index :student_ids
    end
  end
end
