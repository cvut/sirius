Sequel.migration do
  up do
    alter_table(:events) do
      drop_index :teacher_ids
      drop_index :student_ids
      add_index :teacher_ids, type: :gin
      add_index :student_ids, type: :gin
    end

    alter_table(:parallels) do
      add_index :teacher_ids, type: :gin
      add_index :student_ids, type: :gin
    end
  end

  down do
    alter_table(:events) do
      drop_index :teacher_ids
      drop_index :student_ids
      add_index :teacher_ids
      add_index :student_ids
    end

    alter_table(:parallels) do
      drop_index :teacher_ids
      drop_index :student_ids
    end
  end
end
