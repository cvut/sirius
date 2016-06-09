Sequel.migration do
  up do
    create_table?(:audits) do
      primary_key :id, type: Bignum
      column :created_at, DateTime, default: Sequel.function(:now), null: false
      column :user_id, String, null: false, default: Sequel.function(:session_user).quoted
      column :action, String, null: false
      column :table_name, String, null: false
      column :primary_key, String, null: false
      column :changed_values, 'jsonb'
    end
  end

  down do
    drop_table(:audits)
  end
end
