require 'celluloid'
require 'sirius/kosapi_client_registry'
require 'actors/etl_producer'
require 'actors/etl_consumer'

# Loads teacher timetables from KOSapi.
class TimetableSource
  include Celluloid
  include ETLProducer
  include ETLConsumer

  def initialize(input, output, faculty_semester)
    self.input = input
    self.output = output
    @faculty_semester = faculty_semester
    @timetables = [].each
  end

  # Fetches all TeacherTimeSlots for a teacher from KOSapi and buffers them
  # for processing by a next pipeline step.
  #
  # @param username [String] teacher username for which teacher timetable slots should be fetched
  def process_row(username)
    logger.debug "Processing #{username}"
    timetables = fetch_timetable(username)
    @timetables = timetables.each
    @username = username
    logger.debug "Finished processing #{username}"
  end

  # @return [Array(KOSapiClient::Entity::TeacherTimetableSlot, String)] a single timetable slot together with its teacher
  def generate_row
    [@timetables.next, @username]
  end

  private

  def fetch_timetable(username)
    logger.debug "Fetching #{username}"
    client = Sirius::KOSapiClientRegistry.instance.client_for_faculty(@faculty_semester.faculty)
    client.teachers.find(username).timetable(semester: @faculty_semester.code)
  end
end
