Sequel.migration do
  up do
    extension :pg_enum
    create_enum :parity, %w(both odd even)
    set_column_type :faculty_semesters, :first_week_parity, :parity, using: '(ENUM_RANGE(NULL::parity))[first_week_parity + 1]'
    set_column_type :semester_periods, :first_week_parity, :parity, using: '(ENUM_RANGE(NULL::parity))[first_week_parity + 1]'
    set_column_type :timetable_slots, :parity, :parity, using: '(ENUM_RANGE(NULL::parity))[parity + 1]'
  end

  down do
    extension :pg_enum
    set_column_type :faculty_semesters, :first_week_parity, :integer, using: '(array_position(ENUM_RANGE(NULL::parity), first_week_parity) - 1)'
    set_column_type :semester_periods, :first_week_parity, :integer, using: '(array_position(ENUM_RANGE(NULL::parity), first_week_parity) - 1)'
    set_column_type :timetable_slots, :parity, :integer, using: '(array_position(ENUM_RANGE(NULL::parity), parity) - 1)'
    drop_enum :parity
  end
end
