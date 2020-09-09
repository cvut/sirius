Sequel.migration do
  change do
    alter_table(:timetable_slots) do
      add_column :start_time, DateTime, default: nil, null: true
      add_column :end_time, DateTime, default: nil, null: true
      add_column :weeks, String, default: nil, null: true
    end
  end
end
