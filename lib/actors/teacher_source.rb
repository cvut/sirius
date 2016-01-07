require 'celluloid'
require 'event'
require 'actors/etl_actor'

class TeacherSource
  include Celluloid
  include ETLActor

  def initialize(output, semester)
    set_output(output)
    @semester = semester
  end

  def run!
    teachers_dataset = Event
      .select { UNNEST(teacher_ids) }
      .distinct
      .where(faculty: @semester.faculty, semester: @semester.code)
    teachers_dataset.map(:unnest).each { |teacher| emit_row(teacher) }
  end
end
