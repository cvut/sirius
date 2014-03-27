Sequel.migration do 
  change do

    create_table :parallels do
      primary_key :id
      String :kos_id
      String :type
      foreign_key :course_id, :courses
      Integer :code
      Integer :capacity
      Integer :occupied
      String :semester
      String :teacher

      # Timestamps
      DateTime :created_at
      DateTime :updated_at
    end

  end
end