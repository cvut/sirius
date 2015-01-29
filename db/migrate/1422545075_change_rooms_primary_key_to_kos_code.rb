Sequel.migration do
  change do
    [:events, :timetable_slots].each do |table|
      add_column table, :room_id_kos, String
      self["UPDATE #{table} AS e SET room_id_kos = r.kos_code FROM rooms AS r WHERE e.room_id = r.id"].update
      drop_column table, :room_id
    end

    alter_table(:rooms) do
      drop_column :id
      drop_index :kos_code
      rename_column :kos_code, :id
      add_primary_key [:id]
    end

    [:events, :timetable_slots].each do |table|
      alter_table(table) do
        rename_column :room_id_kos, :room_id
        add_foreign_key [:room_id], :rooms
      end
    end
  end
end
