require 'celluloid'
require 'actors/teacher_source'
require 'actors/teacher_timetable_slot_source'
require 'actors/teacher_timetable_slot_transformer'
require 'actors/event_destination'
require 'actors/events_cleaner'

# An actor pipeline system for importing teacher timetable slots from KOSapi.
#
# The inputs are: faculty semester, teacher usernames for that semester,
# semester periods (all from the DB) and teacher timetables slots (fetched from KOSapi).
#
# The output is events of type 'teacher_timetable_slot' that are written to the DB.
#
class TeacherTimetableSlotImport
  include Celluloid

  def initialize(semester)
    @actors = []
    @semester = semester
    @actors << Actor[:teacher_source] = TeacherSource.new(
      :teacher_timetable_slot_source, semester)
    @actors << Actor[:teacher_timetable_slot_source] = TeacherTimetableSlotSource.new(
      :teacher_source, :teacher_timetable_slot_transformer, semester)
    @actors << Actor[:teacher_timetable_slot_transformer] = TeacherTimetableSlotTransformer.new(
      :teacher_timetable_slot_source, :event_destination, semester)
    @actors << Actor[:event_destination] = EventDestination.new(
      :teacher_timetable_slot_transformer, :events_cleaner)
    @actors << Actor[:events_cleaner] = EventsCleaner.new(
      :event_destination, :teacher_timetable_slot_import, semester, 'teacher_timetable_slot')
    Actor[:teacher_timetable_slot_import] = self.async
    @condition = Celluloid::Condition.new
    @logger = Logging.logger[self]
  end

  # Runs the import process for the specified semester
  # and blocks until the import is finished.
  def run!
    @logger.info "Starting TeacherTimetableSlotImport actors for #{@semester.code} (#{@semester.faculty})."
    @actors.each do |actor|
      actor.async.start!
    end
    # Send EOF message to teacher source. It will be then passed to TeacherSources
    # output after all rows are read from the database.
    Actor[:teacher_source].async.receive_eof
    @condition.wait # block current thread until condition variable is signalled
  end

  # Terminate all child actors and itself.
  def shutdown!
    @logger.info "Terminating TeacherTimetableSlotImport actors."
    @actors.each(&:terminate)
    terminate
  end

  # Unblock #run! method by signalling condition variable.
  def receive_eof
    @condition.signal
  end
end
