Sequel.migration do
  change do
    alter_table(:events) do
      add_foreign_key :course_id, :courses, type: 'text'
    end
  end
end
