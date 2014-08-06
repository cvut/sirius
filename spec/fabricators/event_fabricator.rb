require 'sequel/extensions/pg_array'
require 'models/event'

Fabricator(:event) do
  name 'Event name'
  note 'Event note'
  starts_at '2014-04-05 14:30'
  ends_at '2014-04-05 16:00'
  teacher_ids Sequel.pg_array(['vomackar'])
  student_ids Sequel.pg_array(['skocdpet'])
end
