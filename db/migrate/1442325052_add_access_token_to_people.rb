Sequel.migration do
  up do
    self << 'CREATE EXTENSION IF NOT EXISTS pgcrypto'
    alter_table(:people) do
      add_column :access_token, :uuid, default: Sequel.function(:gen_random_uuid), unique: true
    end
    self << <<-EOS
      UPDATE people
      SET access_token = tokens.uuid
      FROM tokens
      WHERE people.id = tokens.username
    EOS
  end

  down do
    drop_column :people, :access_token
    self << 'DROP EXTENSION IF EXISTS pgcrypto'
  end
end
