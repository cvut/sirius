Sequel.migration do
  change do
    alter_table :events do
      add_foreign_key :room_id, :rooms
    end
  end
end
