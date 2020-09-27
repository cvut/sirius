Sequel.migration do
  change do
    alter_table(:timetable_slots) do
      set_column_allow_null :parity
      set_column_allow_null :first_hour
      set_column_allow_null :duration
    end
  end
end
