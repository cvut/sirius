Sequel.migration do
  up do
    alter_table(:events) do
      add_column :applied_schedule_exception_ids, 'bigint[]'
    end
  end

  down do
    alter_table(:schedule_exceptions) do
      drop_column :applied_schedule_exception_ids
    end
  end
end
