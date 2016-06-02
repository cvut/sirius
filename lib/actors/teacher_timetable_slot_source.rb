require 'celluloid'
require 'sirius/kosapi_client_registry'
require 'actors/etl_producer'
require 'actors/etl_consumer'

# Loads teacher timetable slots from KOSapi.
class TeacherTimetableSlotSource
  include Celluloid
  include ETLProducer
  include ETLConsumer

  def initialize(input, output, faculty_semester)
    self.input = input
    self.output = output
    @faculty_semester = faculty_semester
    @timetable_slots = [].each
  end

  # Fetches all TeacherTimetableSlots for a teacher from KOSapi and buffers them
  # for processing by a next pipeline step.
  #
  # @param username [String] teacher username for which teacher timetable slots should be fetched
  def process_row(username)
    logger.debug "Started processing teacher timetable slots for #{username}."
    timetable_slots = fetch_teacher_timetable_slots(username)
    @timetable_slots = timetable_slots.each
    @username = username
    logger.debug "Finished processing teacher timetable slots for #{username}."
  end

  # @return [Array(KOSapiClient::Entity::TeacherTimetableSlot, String)] a single timetable slot together with its teacher
  def generate_row
    [@timetable_slots.next, @username]
  end

  private

  def fetch_teacher_timetable_slots(username)
    logger.debug "Fetching teacher timetable slots for #{username}"
    client = Sirius::KOSapiClientRegistry.instance.client_for_faculty(@faculty_semester.faculty)
    client.teachers.find(username).timetable(semester: @faculty_semester.code)
  end
end
