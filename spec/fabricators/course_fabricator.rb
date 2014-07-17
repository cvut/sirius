require 'models/course'

Fabricator(:course) do
  id { sequence(:course) { |i| "MI-PSL.#{i}" }  }
  department '18102'
  name Sequel.hstore({cs:'Programování v jazyku Scala', en: 'Programming in Scala'})
end
