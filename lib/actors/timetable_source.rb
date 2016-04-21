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
    set_input(input)
    set_output(output)
    @faculty = faculty_semester.faculty
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
    client = Sirius::KOSapiClientRegistry.instance.client_for_faculty(@faculty)
    client.teachers.find(username).timetable
  end
end
