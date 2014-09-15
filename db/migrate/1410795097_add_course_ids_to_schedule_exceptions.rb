Sequel.migration do
  up do
    alter_table(:schedule_exceptions) do
      add_column :course_ids, 'text[]'
    end
  end

  down do
    alter_table(:schedule_exceptions) do
      drop_column :course_ids
    end
  end
end
