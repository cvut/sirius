require 'celluloid'
require 'event'
require 'actors/etl_producer'

# Source of teacher records from the database.
#
# It loads teacher usernames for a specified semester that are assigned to at least one event
# in that semester. Loaded teachers are sent down the pipeline afterwards.
#
class TeacherSource
  include Celluloid
  include ETLProducer

  def initialize(output, semester)
    self.output = output
    @semester = semester
  end

  def generate_row_iterable
    @teachers.next
  end

  def load_teachers
    teachers_dataset = Event
      .select { UNNEST(teacher_ids) }
      .distinct
      .where(faculty: @semester.faculty, semester: @semester.code)
    teachers_dataset.lazy.map { |e| e[:unnest] }
  end

  def start!
    @teachers = load_teachers
    unset_empty
    buffer_empty
  end
end
