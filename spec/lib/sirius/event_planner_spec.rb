require 'spec_helper'
require 'sirius/event_planner'

describe Sirius::EventPlanner do

  subject(:planner) { described_class.new }
  let(:semester) { Fabricate(:faculty_semester) }

  describe '#plan_semester' do

    before { Fabricate(:timetable_slot) }

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
