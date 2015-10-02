Sequel.migration do
  change do
    alter_table(:semester_periods) do
      add_column :first_day_override, Integer
    end
  end
end
