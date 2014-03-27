Sequel.migration do 
  change do

    create_table :timetable_slots do
      primary_key :id
      Integer :day
      Integer :parity
      Integer :first_hour
      Integer :duration

      foreign_key :room_id, :rooms
      foreign_key :parallel_id, :parallels

      # Timestamps
      DateTime :created_at
      DateTime :updated_at
    end

  end
end