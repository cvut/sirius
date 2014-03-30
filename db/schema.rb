Sequel.migration do
  change do
    create_table(:courses) do
      primary_key :id
      column :code, "text"
      column :department, "text"
      column :name, "hstore"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end
    
    create_table(:rooms) do
      primary_key :id
      column :code, "text"
      column :name, "hstore"
      column :capacity, "hstore"
      column :division, "text"
      column :locality, "text"
      column :type, "text"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end
    
    create_table(:schema_migrations) do
      column :filename, "text", :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:events) do
      primary_key :id
      column :name, "text"
      column :note, "text"
      column :starts_at, "timestamp without time zone"
      column :ends_at, "timestamp without time zone"
      column :sequence_number, "integer"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      foreign_key :room_id, :rooms, :key=>[:id]
    end
    
    create_table(:parallels) do
      primary_key :id
      column :kos_id, "text"
      column :type, "text"
      foreign_key :course_id, :courses, :key=>[:id]
      column :code, "integer"
      column :capacity, "integer"
      column :occupied, "integer"
      column :semester, "text"
      column :teacher, "text"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end
    
    create_table(:timetable_slots) do
      primary_key :id
      column :day, "integer"
      column :parity, "integer"
      column :first_hour, "integer"
      column :duration, "integer"
      foreign_key :room_id, :rooms, :key=>[:id]
      foreign_key :parallel_id, :parallels, :key=>[:id]
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end
  end
end
Sequel.migration do
  change do
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140326000000_create_hstore.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140326184848_create_events.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140327012704_create_courses.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140327125618_add_timestamps_to_courses.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140327132523_create_parallels.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140327134045_create_rooms.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140327134320_create_timetable_slots.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140327154417_add_room_fk_to_events.rb')"
  end
end
