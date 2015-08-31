Sequel.migration do
  change do
    create_table(:semester_periods) do
      primary_key :id, type: Bignum
      foreign_key :faculty_semester_id, :faculty_semesters, index: true

      Date :starts_at, null: false
      Date :ends_at, null: false
      Integer :type, index: true, null: false
      Integer :first_week_parity, null: true
      # Timestamps
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
