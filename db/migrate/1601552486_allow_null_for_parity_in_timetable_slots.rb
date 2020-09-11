Sequel.migration do
  change do
    alter_table(:timetable_slots) do
      set_column_allow_null :parity
    end
  end
end
