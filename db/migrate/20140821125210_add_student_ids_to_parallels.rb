Sequel.migration do
  change do
    alter_table :parallels do
      add_column :student_ids, 'text[]'
    end
  end
end
