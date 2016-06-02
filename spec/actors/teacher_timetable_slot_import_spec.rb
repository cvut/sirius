require 'spec_helper'
require 'actors/teacher_timetable_slot_import'

describe TeacherTimetableSlotImport do
  include ActorHelper

  let(:faculty_semester) { Fabricate(:faculty_semester) }
  subject(:import) { described_class.new(faculty_semester) }

  describe '#run!' do
    it 'keeps the actor alive' do
      import.run!
      expect(import).to be_alive
    end
  end

  describe 'shutdown!' do
    it 'terminates the actor' do
      import.shutdown!
      expect(import).to be_dead
    end
  end
end
