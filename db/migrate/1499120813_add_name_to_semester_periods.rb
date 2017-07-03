Sequel.migration do
  change do
    alter_table(:semester_periods) do
      add_column :name, 'hstore'
    end
  end
end
