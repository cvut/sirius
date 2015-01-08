require 'models/faculty_semester'
require 'interactors/import_updated_parallels'
require 'interactors/import_students'
require 'interactors/assign_people'
require 'interactors/import_course_events'
require 'interactors/import_exams'
require 'interactors/import_exam_students'
require 'sirius/event_planner'

module Sirius
  class ScheduleManager

    def initialize
      @active_semesters = FacultySemester.active
    end

    def plan_stored_parallels
      @active_semesters.each do |semester|
        DB.transaction do
          EventPlanner.new.plan_semester(semester)
        end
      end
    end

    def import_parallels(fetch_all: true)
      @active_semesters.each do |sem|
        DB.transaction do
          ImportUpdatedParallels.perform(faculty: sem.faculty, semester: sem.code, fetch_all: fetch_all)
        end
      end
    end

    def import_students
      perform_with_active_semesters(ImportStudents)
    end

    def assign_people
      perform_with_active_semesters(AssignPeople)
    end

    def import_course_events
      perform_with_active_semesters(ImportCourseEvents)
    end

    def import_exams
      perform_with_active_semesters(ImportExams)
    end

    def import_exam_students
      perform_with_active_semesters(ImportExamStudents)
    end

    private
    def perform_with_active_semesters(interactor_class)
      @active_semesters.each do |sem|
        DB.transaction do
          interactor_class.perform(faculty_semester: sem)
        end
      end
    end

  end
end
