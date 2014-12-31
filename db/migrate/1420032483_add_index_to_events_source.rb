Sequel.migration do
  up do
    alter_table(:events) do
      add_index :source, type: :gin
    end
  end

  down do
    alter_table(:events) do
      drop_index :source
    end
  end
end
