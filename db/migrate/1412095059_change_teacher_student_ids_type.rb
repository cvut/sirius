Sequel.migration do
  up do
    alter_table(:events) do
      set_column_type :teacher_ids, 'text[]'
      set_column_type :student_ids, 'text[]'
    end
  end

  down do
    alter_table(:events) do
      set_column_type :teacher_ids, 'character varying(50)[]'
      set_column_type :student_ids, 'character varying(50)[]'
    end
  end
end
