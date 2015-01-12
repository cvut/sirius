require 'active_support/core_ext/numeric/time'
require 'interpipe/interactor'

require 'roles/imported_exam'

class ConvertExams
  include Interpipe::Interactor

  def perform(exams:, faculty_semester:, rooms:, **args)
    @courses = {}
    @people = {}
    @faculty_semester = faculty_semester
    @rooms_map = build_room_map(rooms)
    @events = exams.map do |exam|
      convert_exam(exam)
    end
  end

  def results
    {
      events: @events,
      courses: @courses.values,
      people: @people.values
    }
  end

  def convert_exam(exam)
    event = ImportedExam.played_by(exam) do |exam|
      Event.new(
        starts_at: exam.start_date,
        ends_at: exam.end_date,
        course_id: exam.course.link_id,
        teacher_ids: [],
        capacity: exam.capacity,
        event_type: exam.event_type,
        source: Sequel.hstore({exam_id: exam.link.link_id}),
        semester: @faculty_semester.code,
        faculty: @faculty_semester.faculty
      )
    end
    event.room = @rooms_map[exam.room.link_id] if exam.room
    event.teacher_ids = [exam.examiner.link_id] if exam.examiner
    export_course(exam.course)
    export_person(exam.examiner) if exam.examiner
    event
  end

  def export_person(person_link)
    username = person_link.link_id
    @people[username] ||= Person.new(full_name: person_link.link_title) { |p| p.id = username }
  end

  def export_course(course_link)
    course_code = course_link.link_id
    @courses[course_code] ||= Course.new(name: Sequel.hstore({cs: course_link.link_title})) { |c| c.id = course_code }
  end

  def build_room_map(rooms)
    Hash[rooms.map{|room| [room.kos_code, room]}]
  end

end
