Sequel.migration do
  change do
    alter_table(:parallels) do
      add_column :faculty, Integer
      add_index :faculty
    end
  end
end
