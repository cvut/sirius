Sequel.migration do
  up do
    extension :pg_enum
    create_enum :semester_period_type, %w(teaching exams holiday)
    set_column_type :semester_periods, :type, :semester_period_type, using: '(ENUM_RANGE(NULL::semester_period_type))[type + 1]'
  end

  down do
    extension :pg_enum
    set_column_type :semester_periods, :type, :integer, using: '(array_position(ENUM_RANGE(NULL::semester_period_type), type) - 1)'
    drop_enum :semester_period_type
  end
end
