Sequel.migration do
  up do
    drop_table(:tokens, :update_logs)
  end
end
