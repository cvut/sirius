require 'api_spec_helper'

describe API::SemestersEndpoints do
  include_context 'API response'

  subject { body }

  describe 'GET /semesters' do

    let(:path) { '/semesters' }
    let(:json_type) { 'semesters' }
    let(:total_count) { 3 }

    before do
      i = 0
      Fabricate.times(total_count, :faculty_semester) do
        code { "B1#{ i+=1 }1" }
      end
    end

    it_behaves_like 'secured resource'

    context 'for authenticated user', authenticated: true do
      it_behaves_like 'paginated resource'
    end
  end

  describe 'GET /semesters/:faculty_semester' do

    let(:path) { "/semesters/#{entity.faculty}-#{entity.code}" }
    let!(:entity) { Fabricate(:faculty_semester) }
    let!(:semester_periods) { [
      Fabricate(:teaching_semester_period, faculty_semester: entity),
      Fabricate(:irregular_semester_period, faculty_semester: entity),
      Fabricate(:holiday_semester_period, faculty_semester: entity),
      Fabricate(:exams_semester_period, faculty_semester: entity)
    ] }

    def period_for_json(period)
      ret = {
        type: period.type,
        starts_at: period.starts_at,
        ends_at: period.ends_at,
        irregular: period.irregular
      }
      if period.first_week_parity
        ret[:first_week_parity] = period.first_week_parity
      end
      if period.first_day_override
        ret[:first_day_override] = period.first_day_override
      end
      ret.freeze
    end

    let(:json) do
      {
        id: "#{entity.faculty}-#{entity.code}",
        semester: entity.code,
        faculty: entity.faculty,
        starts_at: entity.starts_at,
        ends_at: entity.ends_at,
        exams_start_at: entity.exams_start_at,
        exams_end_at: entity.exams_end_at,
        teaching_ends_at: entity.teaching_ends_at,
        first_week_parity: entity.first_week_parity,
        hour_duration: entity.hour_duration,
        hour_starts: entity.hour_starts.map { |v| v.strftime('%H:%M') },
        periods: semester_periods.map { |period| period_for_json(period) },
      }.to_json
    end

    it_behaves_like 'secured resource'

    context 'for authenticated user', authenticated: true do

      context 'existing faculty-semester' do
        before { auth_get path_for(path) }

        it 'returns OK' do
          expect(status).to eql 200
        end

        it { should be_json_eql(json).at_path('semesters') }
      end

      context 'non-existing faculty-semester' do
        let(:path) { '/semesters/12345-B141' }
        it_behaves_like 'non-existent resource'
      end
    end
  end
end
