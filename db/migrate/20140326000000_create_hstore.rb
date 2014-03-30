Sequel.migration do
  up do
    run 'CREATE EXTENSION IF NOT EXISTS hstore;'
  end

  down do
    run 'DROP EXTENSION hstore;'
  end
end
