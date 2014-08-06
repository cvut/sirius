require 'models/person'

Fabricator(:person) do
  id { sequence(:username) { |i| "mrdude#{'%02i' % i}" } }
  full_name 'Dude Lebowski'
end
