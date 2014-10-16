Sequel.migration do
  change do
    alter_table(:events) do
      add_index :timetable_slot_id
      add_index :absolute_sequence_number
    end
  end
end
