Sequel.migration do
  up do
    alter_table(:events) do
      drop_column :source
      drop_column :timetable_slot_id
    end
  end

  down do
  end
end
