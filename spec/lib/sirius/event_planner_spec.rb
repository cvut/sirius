require 'spec_helper'
require 'sirius/event_planner'

describe Sirius::EventPlanner do

  subject(:planner) { described_class.new }
  let(:semester) { Fabricate(:faculty_semester, code: 'B141', faculty: 18_000) }

  describe '#plan_semester' do

    let(:parallel) { Fabricate(:parallel, semester: 'B141', faculty: 18_000) }
    let!(:timetable_slot) { Fabricate(:timetable_slot, parallel: parallel) }

    it 'plans all slots stored in DB' do
      expect {
        planner.plan_semester(semester)
      }.to change(Event, :count).from(0)
    end

    it 'synchronizes already generated events' do
      planner.plan_semester(semester)
      expect {
        planner.plan_semester(semester)
      }.not_to change(Event, :count)
    end
  end

end
