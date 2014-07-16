Sequel.migration do
  change do

    create_table :people do
      String :id, primary_key: true
      String :full_name

      # Timestamps
      DateTime :created_at
      DateTime :updated_at
    end

  end
end
