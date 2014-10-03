require 'models/faculty_semester'
require 'interactors/import_updated_parallels'
require 'interactors/import_students'
require 'sirius/event_planner'

module Sirius
  class ScheduleManager

    def initialize
      @active_semesters = FacultySemester.active
    end

    def plan_stored_parallels
      @active_semesters.each do |semester|
        EventPlanner.new.plan_semester(semester)
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

  end
end
