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

  # Teacher username is expected as a row
  def process_row(username)
    logger.debug "Processing #{username}"
    timetables = fetch_timetable(username)
    @timetables = timetables.each
    @username = username
    logger.debug "Finished processing #{username}"
    produce_row if buffer_empty?
  end

  def produce_row_iterable
    output_row([@timetables.next, @username])
  end

  private

  def fetch_timetable(username)
    logger.debug "Fetching #{username}"
    client = Sirius::KOSapiClientRegistry.instance.client_for_faculty(@faculty_semester.faculty)
    client.teachers.find(username).timetable(semester: @faculty_semester.code)
  end
end
