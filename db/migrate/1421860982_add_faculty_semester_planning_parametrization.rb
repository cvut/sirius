Sequel.migration do
  change do
    alter_table :faculty_semesters do
      add_column :update_other, TrueClass, null: false, default: false
      rename_column :update_enabled, :update_parallels
    end
  end
end
