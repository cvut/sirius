Sequel.migration do
  up do
    alter_table(:rooms) do
      rename_column :code, :kos_code
      add_index :kos_code, unique: true
    end
  end

  down do
    alter_table(:rooms) do
      drop_index :kos_code
      rename_column :kos_code, :code
    end
  end
end
