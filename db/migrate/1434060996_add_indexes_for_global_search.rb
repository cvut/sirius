Sequel.migration do
  up do
    [:courses, :people, :rooms].each do |table|
      run "CREATE INDEX #{table}_id_trgm_index ON #{table} USING gin(id gin_trgm_ops)"
    end
  end

  down do
    [:courses, :people, :rooms].each do |table|
      alter_table(table) do
        drop_index :id, name: "#{table}_id_trgm_index"
      end
    end
  end
end
