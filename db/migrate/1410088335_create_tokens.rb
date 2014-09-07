Sequel.migration do
  change do
    create_table(:tokens) do
      uuid :uuid, primary_key: true
      String :username
      DateTime :last_used_at
    end
  end
end
