Sequel.migration do
  change do
    alter_table(:events) do
      add_column :capacity, Integer
    end
  end

end
