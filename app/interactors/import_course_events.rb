require 'interpipe/pipe'
require 'interpipe/aliases'
require 'interactors/sync'
require 'interactors/convert_course_events'
require 'sirius/semester_period_dates_query'

class ImportCourseEvents < Interpipe::Pipe
  include Interpipe::Aliases

  @interactors = [
    FetchResource[:course_events, query_instance: SemesterPeriodDatesQuery.new],
    ConvertCourseEvents,
    split[
      pipe[ ExtractItems[:kosapi_people, from: :course_events, attr: :creator], ConvertPeople, Sync[Person] ],
      pipe[ ExtractItems[:kosapi_courses, from: :course_events, attr: :course], ConvertCourses, Sync[Course] ],
      pipe[ ExtractItems[:kosapi_rooms, from: :course_events, attr: :room], ConvertRooms, Sync[Room] ],
      Sync[Event, matching_attributes: [source: :course_event_id]]
    ]
  ]
end

