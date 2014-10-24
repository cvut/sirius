require 'spec_helper'
require 'interactors/assign_people'

describe AssignPeople do

  describe '#perform' do

    let(:faculty_semester) { Fabricate(:faculty_semester) }
    let(:parallel) { Fabricate(:parallel, student_ids: %w(vomackar dude2), teacher_ids: %w(skocdop)) }
    let(:event) { Fabricate(:event, parallel: parallel, semester: faculty_semester.code, faculty: faculty_semester.faculty, teacher_ids: []) }

    it 'assigns students from parallel to event' do
      expect do
        described_class.perform(faculty_semester: faculty_semester)
        event.refresh
      end.to change(event, :student_ids).to(%w(vomackar dude2))
    end

    it 'assigns teachers from parallel to event' do
      expect do
        described_class.perform(faculty_semester: faculty_semester)
        event.refresh
      end.to change(event, :teacher_ids).to(%w(skocdop))
    end

    it 'updates only events from given semester' do
      event.update(semester: 'B132')
      expect do
        described_class.perform(faculty_semester: faculty_semester)
        event.refresh
      end.not_to change(event, :teacher_ids)
    end

    it 'updates only events from given faculty' do
      event.update(faculty: 13_000)
      expect do
        described_class.perform(faculty_semester: faculty_semester)
        event.refresh
      end.not_to change(event, :teacher_ids)
    end

  end

end
