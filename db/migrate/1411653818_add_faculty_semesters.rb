Sequel.migration do
  change do
    create_table(:faculty_semesters) do
      primary_key :id
      String :code, index: true
      Integer :faculty, index: true
      unique [:code, :faculty]
      TrueClass :update_enabled, default: true

      Integer :first_week_parity
      Date :starts_at
      Date :teaching_ends_at
      Date :exams_start_at
      Date :exams_end_at
      Date :ends_at

      # Time grid
      column :hour_starts, 'time without time zone[]'
      Integer :hour_duration

      # Timestamps
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
