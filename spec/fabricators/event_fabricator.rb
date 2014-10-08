require 'sequel/extensions/pg_array'
require 'models/event'

Fabricator(:event) do
  name 'Event name'
  note 'Event note'
  starts_at DateTime.parse('2014-04-05 14:30')
  ends_at DateTime.parse('2014-04-05 16:00')
  teacher_ids ['vomackar']
  student_ids ['skocdpet']
  event_type 'lecture'
  deleted false
  faculty 18_000
  semester 'B141'
end
