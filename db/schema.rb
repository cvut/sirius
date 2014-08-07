Sequel.migration do
  change do
    create_table(:courses) do
      column :id, "text", :default=>Sequel::LiteralString.new("nextval('courses_id_seq'::regclass)"), :null=>false
      column :department, "text"
      column :name, "hstore"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      
      primary_key [:id]
    end
    
    create_table(:people) do
      column :id, "text", :null=>false
      column :full_name, "text"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      
      primary_key [:id]
    end
    
    create_table(:rooms) do
      primary_key :id
      column :kos_code, "text"
      column :name, "hstore"
      column :capacity, "hstore"
      column :division, "text"
      column :locality, "text"
      column :type, "text"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      
      index [:kos_code], :unique=>true
    end
    
    create_table(:schema_migrations) do
      column :filename, "text", :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:update_logs) do
      primary_key :id
      column :type, "integer"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end
    
    create_table(:parallels) do
      primary_key :id
      column :parallel_type, "text"
      foreign_key :course_id, :courses, :type=>"text", :key=>[:id]
      column :code, "integer"
      column :capacity, "integer"
      column :occupied, "integer"
      column :semester, "text"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      column :teacher_ids, "text[]"
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
    
    create_table(:events) do
      primary_key :id
      column :name, "text"
      column :note, "text"
      column :starts_at, "timestamp without time zone"
      column :ends_at, "timestamp without time zone"
      column :absolute_sequence_number, "integer"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      foreign_key :room_id, :rooms, :key=>[:id]
      column :teacher_ids, "character varying(50)[]"
      column :student_ids, "character varying(50)[]"
      column :relative_sequence_number, "integer"
      column :deleted, "boolean"
      column :event_type, "text"
      foreign_key :parallel_id, :parallels, :key=>[:id]
      foreign_key :timetable_slot_id, :timetable_slots, :key=>[:id]
      foreign_key :course_id, :courses, :type=>"text", :key=>[:id]
      
      index [:student_ids]
      index [:teacher_ids]
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
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140710143245_update_rooms.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140716225640_courses_pk.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140716231715_create_people.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140716235800_add_teachers_parallels.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140717165013_delete_duplicate_parallels_columns.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140717175952_rename_type_to_parallel_type.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140717180517_drop_course_code.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140718175201_events_extension.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140724005656_create_update_log.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140807132353_add_course_id_to_events.rb')"
  end
end
