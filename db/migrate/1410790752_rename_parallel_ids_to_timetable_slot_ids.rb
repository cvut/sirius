Sequel.migration do
  up do
    alter_table(:schedule_exceptions) do
      rename_column :parallel_ids, :timetable_slot_ids
    end
  end

  down do
    alter_table(:schedule_exceptions) do
      rename_column :timetable_slot_ids, :parallel_ids
    end
  end
end
