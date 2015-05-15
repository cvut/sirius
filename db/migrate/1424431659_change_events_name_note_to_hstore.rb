Sequel.migration do
  up do
    set_column_type :events, :name, 'hstore', using: 'NULL'
    set_column_type :events, :note, 'hstore', using: 'NULL'
  end

  down do
    set_column_type :events, :name, String
    set_column_type :events, :note, String
  end
end
