require 'models/faculty_semester'
require 'interactors/import_updated_parallels'
require 'interactors/import_students'
require 'interactors/assign_people'
require 'interactors/import_exams'
require 'interactors/import_exam_students'
require 'interactors/import_course_events'
require 'interactors/import_course_event_students'
require 'interactors/renumber_events'
require 'sirius/event_planner'
require 'actors/teacher_timetable_import'

module Sirius
  class ScheduleManager

    def plan_stored_parallels
      active_semesters(:parallels).each do |semester|
        DB.transaction do
          EventPlanner.new.plan_semester(semester)
        end
      end
    end

    def import_parallels(fetch_all: true, page_size: 100)
      active_semesters(:parallels).each do |sem|
        DB.transaction do
          ImportUpdatedParallels.perform(faculty_semester: sem, fetch_all: fetch_all, page_size: page_size)
        end
      end
    end

    def import_students
      perform_with_active_semesters(ImportStudents, :parallels)
    end

    def assign_people
      perform_with_active_semesters(AssignPeople, :parallels)
    end

    def import_course_events
      perform_with_active_semesters(ImportCourseEvents, :course_events)
    end

    def import_course_event_students
      perform_with_active_semesters(ImportCourseEventStudents, :course_events)
    end

    def import_exams
      perform_with_active_semesters(ImportExams, :exams)
    end

    def import_exam_students
      perform_with_active_semesters(ImportExamStudents, :exams)
    end

    def import_teacher_timetables
      active_semesters(:teacher_timetables).each do |sem|
        TeacherTimetableImport.new(sem).run!
      end
    end

    def renumber_events
      perform_with_active_semesters(RenumberEvents, :events)
    end

    private
    def perform_with_active_semesters(interactor_class, source_type)
      active_semesters(source_type).each do |sem|
        DB.transaction do
          interactor_class.perform(faculty_semester: sem)
        end
      end
    end

    def active_semesters(source_type)
      FacultySemester.active_for(source_type)
    end

  end
end
