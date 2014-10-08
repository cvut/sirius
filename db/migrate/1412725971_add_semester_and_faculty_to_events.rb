Sequel.migration do
  change do
    alter_table(:events) do
      add_column :semester, String
      add_column :faculty, Integer
      add_index :semester
      add_index :faculty
    end
  end
end
