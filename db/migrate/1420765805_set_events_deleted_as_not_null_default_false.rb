Sequel.migration do
  up do
    self[:events].where(deleted: nil).update(deleted: false)
    alter_table(:events) do
      set_column_default :deleted, false
      set_column_not_null :deleted
    end
  end

  down do
    alter_table(:events) do
      set_column_allow_null :deleted
      set_column_default :deleted, nil
    end
  end
end
