Sequel.migration do 
  change do

    create_table :rooms do
      primary_key :id
      String :code
      Hstore :name
      Hstore :capacity
      String :division
      String :locality
      String :type

      # Timestamps
      DateTime :created_at
      DateTime :updated_at
    end

  end
end