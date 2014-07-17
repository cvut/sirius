Sequel.migration do
  change do
    alter_table(:courses) do
      drop_column :code
    end
  end
end
