Sequel.migration do
  change do
    alter_table(:events) do
      add_index :course_id
      add_index :room_id
    end
  end
end
