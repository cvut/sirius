require 'api_spec_helper'
require 'api/faculties_endpoints'
require 'sirius_api/semester_day'
require 'sirius_api/semester_schedule'

describe API::FacultiesEndpoints do
  include_context 'API response'

  let!(:faculty) { Fabricate(:faculty_semester).faculty }


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
end
