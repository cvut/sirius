Sequel.migration do
  up do
    extension :pg_enum
    create_enum :exception_type, %w(cancel relative_move room_change teacher_change)
    set_column_type :schedule_exceptions, :exception_type, :exception_type, using: '(ENUM_RANGE(NULL::exception_type))[exception_type + 1]'
  end

  down do
    extension :pg_enum
    set_column_type :schedule_exceptions, :exception_type, :integer, using: '(array_position(ENUM_RANGE(NULL::exception_type), exception_type) - 1)'
    drop_enum :exception_type
  end
end
