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

  describe '#renumber_events' do

    let(:parallel) { Fabricate(:parallel) }
    # reverse order of generated events is intentional
    let!(:events) { Fabricate.times(4, :event, parallel: parallel) { period Fabricate.sequence(:event_period) { |i| Period.parse("11:#{59 - i}", "12:#{59 - i}") } } }

    it 'calculates order of events from single parallel' do
      planner.renumber_events
      events.each { |e| e.refresh }
      expect(events.map(&:sequence_number)).to eq [4, 3, 2, 1]
    end

    it 'skips deleted events' do
      events[1].deleted = true
      events[1].save
      planner.renumber_events
      events.each { |e| e.refresh }
      expect(events.map(&:sequence_number)).to eq [3, nil, 2, 1]
    end

    it 'calculates order of events from two parallels independently' do
      parallel2 = Fabricate(:parallel)
      events[2].parallel = events[0].parallel = parallel2
      events.each { |e| e.save }
      planner.renumber_events
      events.each { |e| e.refresh }
      expect(events.map(&:sequence_number)).to eq [2, 2, 1, 1]
    end

  end

end
