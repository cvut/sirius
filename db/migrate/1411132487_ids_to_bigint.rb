Sequel.migration do
  # Mass convert type of given columns in given tables
  IDS_MAPPING ||= {
    events: %i(id parallel_id),
    schedule_exceptions: :id,
    parallels: :id,
    timetable_slots: %i(id parallel_id),
    update_logs: :id,
    events: :timetable_slot_id,
  }

  IDS_ARR_MAPPING ||= {
    schedule_exceptions: :timetable_slot_ids
  }

  up do
    IDS_MAPPING.each do |tbl, cols|
      cols = Array(cols)
      alter_table(tbl) do
        cols.each do |col|
          set_column_type col, Bignum
        end
      end
    end
    IDS_ARR_MAPPING.each do |tbl, col|
      alter_table(tbl) do
        set_column_type col, 'bigint[]'
      end
    end
  end

  down do
    IDS_MAPPING.each do |tbl, cos|
      cols = Array(cols)
      alter_table(tbl) do
        cols.each do |col|
          set_column_type col, Fixnum
        end
      end
    end
    IDS_ARR_MAPPING.each do |tbl, col|
      alter_table(tbl) do
        set_column_type col, 'integer[]'
      end
    end
  end
end
