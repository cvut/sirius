Sequel.migration do
  up do
    alter_table(:events) do
      add_column :source, 'hstore'
    end
  end

  down do
    alter_table(:events) do
      drop_column :source
    end
  end
end
