Sequel.migration do
  change do
    alter_table(:parallels) do
      drop_column :kos_id
      drop_column :teacher
    end
  end
end
