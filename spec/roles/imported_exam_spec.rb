require 'spec_helper'
require 'roles/imported_exam'

describe ImportedExam do

  subject(:imported_exam) { described_class.new(wrapped_exam) }

  describe '#event_type' do

    context 'with assessment' do
      let(:wrapped_exam) { double(term_type: :assessment)}
      it 'returns assessment according to source' do
        expect(imported_exam.event_type).to eq 'assessment'
      end
    end

    context 'with final exam' do
      let(:wrapped_exam) { double(term_type: :final_exam)}
      it 'returns exam otherwise' do
        expect(imported_exam.event_type).to eq 'exam'
      end
    end
  end

  describe '#end_date' do

    let(:start_date) { Time.new }
    let(:end_date) { start_date + 10.minutes }
    let(:wrapped_exam) { spy(start_date: start_date, end_date: end_date)}

    it 'returns end_date when set' do
      expect(imported_exam.end_date).to eq end_date
    end

    context 'with missing end_date' do
      let(:end_date) { nil }
      it 'returns end_date 90 minutes from start_date' do
        expect(imported_exam.end_date).to eq start_date + 90.minutes
      end
    end

  end

end
