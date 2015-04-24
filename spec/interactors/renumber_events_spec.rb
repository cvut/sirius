require 'spec_helper'
require 'interactors/renumber_events'

describe RenumberEvents do

  subject(:planner) { described_class.new }
  let(:semester) { Fabricate(:faculty_semester, code: 'B141', faculty: 18_000) }

  describe '#renumber_events' do

    let(:parallel) { Fabricate(:parallel) }
    # reverse order of generated events is intentional
    let!(:events) { Fabricate.times(4, :event, parallel: parallel) { period Fabricate.sequence(:event_period) { |i| Period.parse("11:#{59 - i}", "12:#{59 - i}") } } }

    it 'calculates order of events from single parallel' do
      planner.perform(faculty_semester: semester)
      events.each { |e| e.refresh }
      expect(events.map(&:sequence_number)).to eq [4, 3, 2, 1]
    end

    it 'skips deleted events' do
      events[1].deleted = true
      events[1].save
      planner.perform(faculty_semester: semester)
      events.each { |e| e.refresh }
      expect(events.map(&:sequence_number)).to eq [3, nil, 2, 1]
    end

    it 'calculates order of events from two parallels independently' do
      parallel2 = Fabricate(:parallel)
      events[2].parallel = events[0].parallel = parallel2
      events.each { |e| e.save }
      planner.perform(faculty_semester: semester)
      events.each { |e| e.refresh }
      expect(events.map(&:sequence_number)).to eq [2, 2, 1, 1]
    end

    it 'modifies only events from given semester and faculty' do
      events = [ Fabricate(:event, faculty: 13_000), Fabricate(:event, semester: 'B142') ]
      planner.perform(faculty_semester: semester)
      events.each { |e| e.refresh }
      expect(events.map(&:sequence_number)).to eq [nil, nil]
    end

    it 'separates different event types' do
      events = [ Fabricate(:event, event_type: :exam), Fabricate(:event, event_type: :tutorial) ]
      planner.perform(faculty_semester: semester)
      events.each(&:refresh)
      expect(events.map(&:sequence_number)).to eq [1, 1]
    end

    it 'separates different courses' do
      Fabricate(:course, id: 'BI-MLO')
      Fabricate(:course, id: 'MI-PAR')
      events = [ Fabricate(:event, course_id: 'BI-MLO'), Fabricate(:event, course_id: 'MI-PAR') ]
      planner.perform(faculty_semester: semester)
      events.each(&:refresh)
      expect(events.map(&:sequence_number)).to eq [1, 1]
    end
  end
end
