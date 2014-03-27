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
    
    create_table(:events) do
      primary_key :id
      column :name, "text"
      column :note, "text"
      column :starts_at, "timestamp without time zone"
      column :ends_at, "timestamp without time zone"
      column :sequence_number, "integer"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end
    
    create_table(:schema_migrations) do
      column :filename, "text", :null=>false
      
      primary_key [:filename]
    end
  end
end
Sequel.migration do
  change do
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140326184848_create_events.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140327012704_create_courses.rb')"
    self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20140327125618_add_timestamps_to_courses.rb')"
  end
end
