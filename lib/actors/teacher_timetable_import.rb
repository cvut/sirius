require 'celluloid'
require 'actors/teacher_source'
require 'actors/timetable_source'
require 'actors/timetable_transformer'
require 'actors/event_destination'
require 'actors/teacher_timetables_cleaner'

# An actor pipeline system for importing teacher timetables from KOSapi.
#
# The inputs are: faculty semester, teacher usernames for that semester,
# semester periods (all from the DB) and teacher timetables (fetched from KOSapi).
#
# The output is events of type 'teacher_timetable' that are written to the DB.
#
class TeacherTimetableImport
  include Celluloid

  def initialize(semester)
    @actors = []
    @semester = semester
    @actors << Actor[:teacher_source] = TeacherSource.new(:timetable_source, semester)
    @actors << Actor[:timetable_source] = TimetableSource.new(:teacher_source, :timetable_transformer, semester)
    @actors << Actor[:timetable_transformer] = TimetableTransformer.new(:timetable_source, :event_destination, semester)
    @actors << Actor[:event_destination] = EventDestination.new(:timetable_transformer, :teacher_timetables_cleaner)
    @actors << Actor[:teacher_timetables_cleaner] = TeacherTimetablesCleaner.new(:event_destination, :teacher_timetable_import, semester)
    Actor[:teacher_timetable_import] = self.async
    @condition = Celluloid::Condition.new
    @logger = Logging.logger[self]
  end

  # Runs the import process for the specified semester
  # and blocks until the import is finished.
  def run!
    @logger.info "Starting TeacherTimetableImport actors for #{@semester.code} (#{@semester.faculty})."
    @actors.each do |actor|
      actor.async.start!
    end
    Actor[:teacher_source].async.receive_eof
    @condition.wait # block current thread until condition variable is signalled
  end

  # Terminate all child actors and itself.
  def shutdown!
    @logger.info "Terminating TeacherTimetableImport actors."
    @actors.each(&:terminate)
    terminate
  end

  # Unblock #run! method by signalling condition variable.
  def receive_eof
    @condition.signal
  end
end
