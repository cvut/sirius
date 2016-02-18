require 'spec_helper'
require 'interactors/assign_people'

describe AssignPeople do

  describe '#perform' do

    let(:faculty_semester) { Fabricate(:faculty_semester) }

    let(:parallel) do
      Fabricate(:parallel,
        student_ids: ['vomackar', 'dude2'],
        teacher_ids: ['skocdop']
      )
    end

    let(:event) do
      Fabricate(:event,
        parallel: parallel,
        semester: faculty_semester.code,
        faculty: faculty_semester.faculty,
        teacher_ids: []
      )
    end

    it 'assigns students from parallel to event' do
      expect {
        described_class.perform(faculty_semester: faculty_semester)
        event.refresh
      }.to change(event, :student_ids).to(%w(vomackar dude2))
    end

    it 'assigns teachers from parallel to event' do
      expect {
        described_class.perform(faculty_semester: faculty_semester)
        event.refresh
      }.to change(event, :teacher_ids).to(%w(skocdop))
    end

    it 'updates only events from given semester' do
      event.update(semester: 'B132')
      expect {
        described_class.perform(faculty_semester: faculty_semester)
        event.refresh
      }.not_to change(event, :teacher_ids)
    end

    it 'updates only events from given faculty' do
      event.update(faculty: 13_000)
      expect {
        described_class.perform(faculty_semester: faculty_semester)
        event.refresh
      }.not_to change(event, :teacher_ids)
    end

    it 'changes updated_at column' do
      expect {
        described_class.perform(faculty_semester: faculty_semester)
        event.refresh
      }.to change(event, :updated_at)
    end

    context 'with not changed event' do

      let(:event) do
        Fabricate(:event,
          parallel: parallel,
          semester: faculty_semester.code,
          faculty: faculty_semester.faculty,
          teacher_ids: ['skocdop'],
          student_ids: ['vomackar', 'dude2'],
          applied_schedule_exception_ids: [exception.id]
        )
      end

      let(:exception) do
        Fabricate(:teacher_change_schedule_exception,
          semester: faculty_semester.code,
          faculty: faculty_semester.faculty,
          options: { teacher_ids: "{skocdop}" }
        )
      end

      it 'does not update records with unchanged data' do
        expect {
          described_class.perform(faculty_semester: faculty_semester)
          event.refresh
        }.not_to change(event, :updated_at)
      end
    end

    context 'with teacher change schedule exception' do

      let(:exception) do
        Fabricate(:teacher_change_schedule_exception,
          semester: faculty_semester.code,
          faculty: faculty_semester.faculty,
          options: { teacher_ids: '{skocdop,vomackar}' }
        )
      end

      before do
        event.update(applied_schedule_exception_ids: [exception.id])
      end

      it 'changes teacher_ids for marked events' do
        expect {
          described_class.perform(faculty_semester: faculty_semester)
          event.refresh
        }.to change(event, :teacher_ids).from([]).to(%w(skocdop vomackar))
      end

      it 'changes updated_at for changed event' do
        expect {
          described_class.perform(faculty_semester: faculty_semester)
          event.refresh
        }.to change(event, :updated_at)
      end
    end

  end

end
