Sequel.migration do
  up do
    alter_table(:events) do
      add_column :original_starts_at, DateTime
      add_column :original_ends_at, DateTime
      add_column :original_room_id, String
    end
  end

  down do
    alter_table(:events) do
      drop_column :original_starts_at
      drop_column :original_ends_at
      drop_column :original_room_id
    end
  end
end
