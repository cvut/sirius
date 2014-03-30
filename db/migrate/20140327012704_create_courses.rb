Sequel.migration do
  change do
    create_table :courses do
      primary_key :id
      String :code
      String :department
      HStore :name
    end
  end
end
