require 'interactors/kosapi_interactor'

class FetchExamStudents < KOSapiInteractor

  def setup(*args)
    super
    @people = {}
  end

  def perform(faculty_semester:, future_exams_only: true)
    client = kosapi_client(faculty_semester)

    @exams = load_exam_events(faculty_semester, future_exams_only).map do |exam|
      students = fetch_exam_students(client, exam)
      update_exam_students(exam, students)
      exam
    end
  end

  def results
    { events: @exams, people: @people.values }
  end

  def load_exam_events(faculty_semester, future_exams_only)
    query = Event.where(event_type: ['exam', 'assessment'], faculty: faculty_semester.faculty, semester: faculty_semester.code)
    query = query.where('starts_at > NOW()') if future_exams_only
    query
  end

  def fetch_exam_students(client, exam)
    client.exams.find(exam.source['exam_id'].to_i).limit(100).attendees
  end

  def update_exam_students(exam, students)
    student_ids = students.map do |student|
      @people[student.username] ||= Person.new(full_name: student.full_name) { |p| p.id = student.username }
      student.username
    end
    exam.student_ids = student_ids
  end

end
