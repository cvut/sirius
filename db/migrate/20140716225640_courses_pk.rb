Sequel.migration do
  transaction
  change do
    alter_table(:parallels) do
      drop_foreign_key [:course_id]
    end
    set_column_type :courses, :id, String
    set_column_type :parallels, :course_id, String
    alter_table(:parallels) do
      add_foreign_key [:course_id], :courses
    end
  end
end
