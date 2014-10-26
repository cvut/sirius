require 'models/faculty_semester'
require 'interactors/import_updated_parallels'
require 'interactors/import_students'
require 'interactors/assign_people'
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
      DB.transaction do
        @active_semesters.each do |sem|
          ImportUpdatedParallels.perform(faculty: sem.faculty, semester: sem.code, fetch_all: fetch_all)
        end
      end
    end

    def import_students
      DB.transaction do
        ImportStudents.perform
      end
    end

    def assign_people
      DB.transaction do
        @active_semesters.each do |sem|
          AssignPeople.perform(faculty_semester: sem)
        end
      end
    end

  end
end
