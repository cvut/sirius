require 'spec_helper'
require 'sirius_api/semester_schedule'

module SiriusApi
  describe SemesterSchedule do

    let(:semester_weeks) { [ Fabricate.build(:semester_week) ] }
    let(:start_date) { semester_weeks.first.start_date + 1 }  # Tuesday
    let(:end_date) { semester_weeks.last.end_date - 3 }  # Thursday
    let(:faculty_id) { 18000 }

    let(:first_day) do
      semester_weeks.flat_map(&:days).find { |day| day.date == start_date }
    end

    before do
      expect(described_class).to receive(:resolve_weeks)
        .with(start_date, end_date, faculty_id)
        .and_return(semester_weeks)
    end


    describe '#resolve_week' do
      subject(:actual) { described_class.resolve_week(start_date, faculty_id) }
      let(:end_date) { start_date }

      context 'known date' do
        it 'returns SemesterWeek that contains the specified date' do
          expect( actual ).to eq semester_weeks.first
        end
      end

      context 'unknown date' do
        let(:semester_weeks) { [] }
        let(:start_date) { Date.parse('2020-06-06') }
        it { should be nil }
      end
    end


    describe '#resolve_days' do
      subject(:actual) do
        described_class.resolve_days(start_date, end_date, faculty_id)
      end

      it 'returns an array of SemesterDays' do
        expect( actual ).to be_instance_of Array
        expect( actual.first ).to eq first_day
      end

      context 'with range covering single week' do
        it 'returns days in the given range' do
          expect( actual.map(&:date) ).to eq start_date.step(end_date).to_a
        end
      end

      context 'with range covering multiple weeks' do
        let(:semester_weeks) { [
          Fabricate.build(:semester_week), Fabricate.build(:semester_week_2)
        ] }

        it 'returns days in the given range' do
          expect( actual.map(&:date) ).to eq start_date.step(end_date).to_a
        end
      end
    end


    describe '#resolve_day' do
      subject(:actual) { described_class.resolve_day(start_date, faculty_id) }
      let(:end_date) { start_date }

      context 'known date' do
        it 'returns correct SemesterDay' do
          expect( actual ).to eq first_day
        end
      end

      context 'unknown date' do
        let(:semester_weeks) { [] }
        let(:start_date) { Date.parse('2020-06-06') }
        it { should be nil }
      end
    end
  end
end
