require 'models/room'

Fabricator(:room) do
  id { sequence(:room, 101) { |i| "T9:#{i}" } }
end
