require 'models/course'

Fabricator(:course) do
  code 'MI-PSL'
  department '18102'
  name Sequel.hstore({cs:'Programování v jazyku Scala', en: 'Programming in Scala'})
end
