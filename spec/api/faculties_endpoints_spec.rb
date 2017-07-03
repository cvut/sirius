require 'api_spec_helper'
require 'api/faculties_endpoints'
require 'sirius_api/semester_day'
require 'sirius_api/semester_schedule'

describe API::FacultiesEndpoints do
  include_context 'API response'

  let!(:faculty_semester) { Fabricate(:faculty_semester) }
  let!(:faculty) { faculty_semester.faculty }


  describe 'GET /faculties/:code/schedule/days' do

    let(:path) { "/faculties/#{faculty}/schedule/days" }
    let(:from) { Date.today }  # default value
    let(:to) { Date.today + 7 }  # default value
    let(:json_type) { 'semester_days' }
    let(:sem_days) { Fabricate.build_times(2, :semester_day) }

    context 'existing faculty' do
      before do
        expect(SiriusApi::SemesterSchedule).to receive(:resolve_days)
          .with(from, to, faculty).and_return(sem_days)
      end

      context 'with default from and to' do
        it 'returns semester days from today to +7 days' do
          get path_for(path)
          expect( body ).to have_json_size(sem_days.size).at_path(json_type)
        end
      end

      context 'with from and to' do
        let(:from) { Date.today - 7 }
        let(:to) { Date.today + 30 }

        it 'returns semester days in the specified range' do
          get path_for("#{path}?from=#{from}&to=#{to}")
          expect( body ).to have_json_size(sem_days.size).at_path(json_type)
        end
      end
    end

    context 'non-existent faculty' do
      let(:faculty) { 66006 }
      let(:sem_days) { [] }

      before { get path_for(path) }
      it { should be_http_not_found }
    end
  end


  describe 'GET /faculties/:code/schedule/days/:date' do

    let(:path) { "/faculties/#{faculty}/schedule/days/#{date}" }
    let(:sem_day) { Fabricate.build(:semester_day) }
    let(:date) { sem_day.date }

    let(:json) do
      {
        date: sem_day.date,
        period_type: sem_day.period.type,
        irregular: sem_day.irregular,
        teaching_week: sem_day.teaching_week,
        week_parity: sem_day.week_parity,
        cwday: sem_day.cwday,
        links: {
          period: sem_day.period.id,
          semester: "#{sem_day.semester.faculty}-#{sem_day.semester.code}"
        }
      }.to_json
    end

    before do
      expect(SiriusApi::SemesterSchedule).to receive(:resolve_day)
        .with(date, faculty).and_return(sem_day)
    end

    context 'existing faculty' do

      context 'existing date' do
        before { get path_for(path) }

        it { should be_http_ok }
        it { expect( body ).to be_json_eql(json).at_path('semester_days') }
      end

      context 'date "current"' do
        let(:path) { "/faculties/#{faculty}/schedule/days/current" }
        let(:date) { Date.today }

        before { get path_for(path) }

        it 'resolves SemesterDay for the current day' do
          should be_http_ok
        end

        it { expect( body ).to be_json_eql(json).at_path('semester_days') }
      end

      context 'non-existent date' do
        let(:sem_day) { nil }
        let(:date) { Date.parse('2010-05-06') }

        it_behaves_like 'non-existent resource'
      end
    end

    context 'non-existent faculty' do
      let(:sem_day) { nil }
      let(:date) { Date.parse('2014-10-06') }

      it_behaves_like 'non-existent resource'
    end
  end


  describe 'GET /faculties/:code/schedule/weeks' do

    let(:path) { "/faculties/#{faculty}/schedule/weeks" }
    let(:from) { Date.today }  # default value
    let(:to) { Date.today + 7 }  # default value
    let(:json_type) { 'semester_weeks' }
    let(:sem_weeks) { Fabricate.build_times(2, :semester_week) }

    context 'existing faculty' do
      before do
        expect(SiriusApi::SemesterSchedule).to receive(:resolve_weeks)
          .with(from, to, faculty).and_return(sem_weeks)
      end

      context 'with default from and to' do
        it 'returns semester weeks from today to +7 days' do
          get path_for(path)
          expect( body ).to have_json_size(sem_weeks.size).at_path(json_type)
        end
      end

      context 'with from and to' do
        let(:from) { Date.today - 7 }
        let(:to) { Date.today + 30 }

        it 'returns semester weeks in the specified range' do
          get path_for("#{path}?from=#{from}&to=#{to}")
          expect( body ).to have_json_size(sem_weeks.size).at_path(json_type)
        end
      end
    end

    context 'non-existent faculty' do
      let(:faculty) { 66006 }
      let(:sem_weeks) { [] }

      before { get path_for(path) }
      it { should be_http_not_found }
    end
  end


  describe 'GET /faculties/:code/schedule/weeks/:year_cweek' do

    let(:path) { "/faculties/#{faculty}/schedule/weeks/#{year_cweek}" }
    let(:sem_week) { Fabricate.build(:semester_week) }
    let(:year_cweek) { "#{sem_week.cwyear}-#{sem_week.cweek}" }

    let(:json) do
      {
        starts_at: sem_week.start_date,
        ends_at: sem_week.end_date,
        cweek: sem_week.cweek,
        period_types: sem_week.period_types,
        teaching_week: sem_week.teaching_week,
        week_parity: sem_week.week_parity,
        links: {
          semester: "#{sem_week.semester.faculty}-#{sem_week.semester.code}",
          periods: sem_week.periods.map(&:id)
        }
      }.to_json
    end

    context 'syntactically valid parameters' do

      before do
        date = Date.strptime(year_cweek, '%G-%V')
        expect(SiriusApi::SemesterSchedule).to receive(:resolve_week)
          .with(date, faculty).and_return(sem_week)
      end

      context 'existing faculty' do

        context 'existing year-week' do
          before { get path_for(path) }

          it { should be_http_ok }
          it { expect( body ).to be_json_eql(json).at_path('semester_weeks') }
        end

        context 'year-week "current"' do
          let(:path) { "/faculties/#{faculty}/schedule/weeks/current" }
          let(:year_cweek) { Date.today.strftime('%G-%V') }

          before { get path_for(path) }

          it 'resolves SemesterWeek for the current week' do
            should be_http_ok
          end

          it { expect( body ).to be_json_eql(json).at_path('semester_weeks') }
        end

        context 'unknown year-week' do
          let(:sem_week) { nil }
          let(:year_cweek) { "2014-02" }

          it_behaves_like 'non-existent resource'
        end
      end

      context 'non-existent faculty' do
        let(:faculty) { 66006 }
        let(:sem_week) { nil }
        let(:year_cweek) { "2014-45" }

        it_behaves_like 'non-existent resource'
      end
    end

    context 'syntactically invalid parameters' do

      context 'invalid year_cweek' do
        let(:year_cweek) { "2066-99" }

        before { get path_for(path) }
        it { should be_http_bad_request }
      end
    end
  end


  describe 'GET /faculties/:code/semesters' do

    let(:path) { "/faculties/#{faculty}/semesters" }
    let(:json_type) { 'semesters' }
    let(:total_count) { 3 }

    before do
      i = 0                       # one FacultySemester is created at the top
      Fabricate.times(total_count - 1, :faculty_semester) do
        code { "B1#{ i+=1 }1" }
      end
    end

    it_behaves_like 'paginated resource'

    context 'non-existent faculty' do
      let(:faculty) { 66006 }

      before { get path_for(path) }
      it { should be_http_not_found }
    end
  end


  describe 'GET /faculties/:code/semesters/:code' do

    let(:entity) { faculty_semester }
    let(:path) { "/faculties/#{entity.faculty}/semesters/#{entity.code}" }

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
      if period.name
        ret[:name] = period.name
      end
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

    context 'existing faculty-semester' do
      before { get path_for(path) }

      it { should be_http_ok }
      it { expect( body ).to be_json_eql(json).at_path('semesters') }
    end

    context 'non-existent faculty-semester' do
      let(:path) { '/faculties/12345/semesters/B141' }
      it_behaves_like 'non-existent resource'
    end
  end
end
