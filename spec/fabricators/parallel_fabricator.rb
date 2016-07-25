require 'models/parallel'

Fabricator(:parallel) do
  code 101
  capacity 24
  occupied 24
  semester 'B132'
  course
  faculty 18_000
  parallel_type 'lecture'
end
