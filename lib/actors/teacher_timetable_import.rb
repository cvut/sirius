require 'celluloid'
require 'actors/teacher_source'
require 'actors/timetable_source'
require 'actors/timetable_transformer'
require 'actors/event_destination'
require 'actors/etl_actor'

class TeacherTimetableImport
  include Celluloid
  include ETLActor

  def initialize(semester)
    Actor[:teacher_source] = TeacherSource.new(:timetable_source, semester)
    Actor[:timetable_source] = TimetableSource.new(:timetable_transformer, semester)
    Actor[:timetable_transformer] = TimetableTransformer.new(:event_destination, semester)
    Actor[:event_destination] = EventDestination.new(:teacher_timetable_import)
    Actor[:teacher_timetable_import] = self.async
    @condition = Celluloid::Condition.new
  end

  def run!
    Actor[:teacher_source].async.run!
    Actor[:teacher_source].async.receive_eof
    @condition.wait
    terminate
  end

  def receive_eof
    @condition.signal
  end
end
