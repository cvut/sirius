require 'spec_helper'
require 'sirius_api/semester_day'

module SiriusApi
describe SemesterDay do

  subject(:sem_day) { described_class.new(period, date, 1) }
  let(:date) { Date.new(2015, 11, 11) }
  let(:first_day_override) { nil }

  let(:period) do
    Fabricate.build :semester_period,
      type: :teaching,
      starts_at: '2015-11-11',
      ends_at: '2015-11-27',
      first_week_parity: :odd,
      first_day_override: first_day_override
  end

  describe '#date' do
    it { expect( sem_day.date ).to be_frozen }
  end

  describe '#semester' do
    it "returns period's faculty_semester" do
      expect( sem_day.semester ).to be period.faculty_semester
    end
  end

  describe '#cwday/#wday_name' do

    context 'normal day' do
      it "returns a calendar week day" do
        expect( sem_day.cwday ).to eq 3
        expect( sem_day.wday_name ).to eq :wednesday
      end
    end

    context 'date affected by first_day_override' do
      let(:first_day_override) { :tuesday }

      it 'returns a week day shifted by first_day_override' do
        expect( sem_day.cwday ).to eq 2
        expect( sem_day.wday_name ).to eq :tuesday
      end
    end
  end

  describe '#week_parity' do

    it 'returns result of @period.week_parity(@date)' do
      expect( sem_day.period ).to receive(:week_parity).with(date).and_return(:odd)
      expect( sem_day.week_parity ).to eq :odd
    end
  end

end
end
