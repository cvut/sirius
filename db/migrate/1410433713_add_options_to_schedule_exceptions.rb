Sequel.migration do
  up do
    alter_table(:schedule_exceptions) do
      add_column :options, 'hstore'
    end
  end

  down do
    alter_table(:schedule_exceptions) do
      drop_column :options
    end
  end
end
