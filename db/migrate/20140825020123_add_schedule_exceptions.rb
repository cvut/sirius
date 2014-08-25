Sequel.migration do
  change do
    create_table(:schedule_exceptions) do

      primary_key :id
      Integer :exception_type
      String :name
      String :note
      DateTime :starts_at
      DateTime :ends_at
      Integer :faculty
      String :semester
      column :parallel_ids, 'integer[]'

      # Timestamps
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
