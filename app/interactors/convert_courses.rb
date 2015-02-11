require 'interpipe/interactor'
require 'course'

class ConvertCourses
  include Interpipe::Interactor

  def perform(kosapi_courses:, **opts)
    @courses = kosapi_courses.map { |course| convert_course(course) }
  end

  def results
    { courses: @courses }
  end

  def convert_course(course_link)
    course_code = course_link.link_id
    Course.new(name: Sequel.hstore({cs: course_link.link_title})) { |c| c.id = course_code }
  end
end
