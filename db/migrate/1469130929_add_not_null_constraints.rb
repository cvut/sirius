Sequel.migration do
  NOT_NULL_COLUMNS = {
    courses: %i{
      name
      created_at
      updated_at
    },
    events: %i{
      starts_at
      ends_at
      created_at
      updated_at
      event_type
      source_type
      semester
    },
    faculty_semesters: %i{
      code
      faculty
      update_parallels
      first_week_parity
      starts_at
      teaching_ends_at
      exams_start_at
      ends_at
      hour_starts
      hour_duration
      created_at
      updated_at
    },
    parallels: %i{
      parallel_type
      course_id
      code
      semester
      created_at
      updated_at
      faculty
    },
    people: %i{
      full_name
      access_token
      created_at
      updated_at
    },
    rooms: %i{
      created_at
      updated_at
    },
    schedule_exceptions: %i{
      exception_type
      name
      created_at
      updated_at
    },
    semester_periods: %i{
      faculty_semester_id
      created_at
      updated_at
    },
    timetable_slots: %i{
      day
      parity
      first_hour
      duration
      parallel_id
      created_at
      updated_at
    }
  }

  up do
    NOT_NULL_COLUMNS.each do |table, columns|
      alter_table(table) do
        columns.each { |column| set_column_not_null column }
      end
    end
  end

  down do
    NOT_NULL_COLUMNS.each do |table, columns|
      alter_table(table) do
        columns.each { |column| set_column_allow_null column }
      end
    end
  end
end
