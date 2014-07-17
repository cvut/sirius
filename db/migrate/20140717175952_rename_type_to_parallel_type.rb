Sequel.migration do
  change do
    alter_table(:parallels) do
      rename_column :type, :parallel_type
    end
  end
end
