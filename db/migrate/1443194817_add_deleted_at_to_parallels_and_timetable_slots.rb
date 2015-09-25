Sequel.migration do
  change do
    [:parallels, :timetable_slots].each do |table|
      alter_table(table) do
        add_column :deleted_at, DateTime
        add_index :deleted_at
      end
    end
  end
end
