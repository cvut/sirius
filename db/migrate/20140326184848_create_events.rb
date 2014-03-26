Sequel.migration do 
  change do

    create_table :events do
      primary_key :id
      String :name
      String :note
      DateTime :starts_at
      DateTime :ends_at
      Integer :sequence_number

      # Timestamps
      DateTime :created_at
      DateTime :updated_at
    end

  end
end