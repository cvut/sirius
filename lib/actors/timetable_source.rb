require 'celluloid'
require 'sirius/kosapi_client_registry'
require 'actors/etl_actor'

# Loads teacher timetables from KOSapi.
class TimetableSource
  include Celluloid
  include ETLActor

  def initialize(output, faculty_semester)
    set_output(output)
    @faculty = faculty_semester.faculty
  end

  # Teacher username is expected as a row
  def process_row(username)
    timetable = fetch_timetable(username)
    timetable.each { |slot| emit_row(slot, username) }
  end

  private

  def fetch_timetable(username)
    client = Sirius::KOSapiClientRegistry.instance.client_for_faculty(@faculty)
    client.teachers.find(username).timetable
  end
end
