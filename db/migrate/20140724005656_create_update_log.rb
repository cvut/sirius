Sequel.migration do
  change do
    create_table :update_logs do
      primary_key :id
      Integer :type

      # Timestamps
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
