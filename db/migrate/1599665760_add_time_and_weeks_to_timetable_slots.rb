Sequel.migration do
  change do
    alter_table(:timetable_slots) do
      add_column :start_time, Time, only_time: true, default: nil, null: true
      add_column :end_time, Time, only_time: true, default: nil, null: true
      add_column :weeks, 'int4range[]', default: nil, null: true
    end
  end
end
