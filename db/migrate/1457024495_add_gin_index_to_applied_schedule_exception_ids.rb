Sequel.migration do
  up do
    add_index :events, :applied_schedule_exception_ids, type: :gin
  end

  down do
    drop_index :events, :applied_schedule_exception_ids
  end
end
