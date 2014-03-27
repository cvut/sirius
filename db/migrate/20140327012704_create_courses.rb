Sequel.migration do 
  change do

    run 'CREATE EXTENSION hstore;'

    create_table :courses do
      primary_key :id
      String :code
      String :department
      HStore :name
    end

  end
end