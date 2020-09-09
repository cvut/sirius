Sequel.migration do
  change do
    alter_table(:timetable_slots) do
      add_column :weeks, 'integer[]', null: true
    end
  end
end
