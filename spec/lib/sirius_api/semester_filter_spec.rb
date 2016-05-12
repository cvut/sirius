require 'spec_helper'

# @deprecated
describe SiriusApi::SemesterFilter do
  subject(:filter) { described_class.new }
  let(:dataset) { FacultySemester.dataset }

  describe '#filter' do
    context 'without extra params' do
      it 'does not modify given dataset' do
        res = filter.filter(dataset, {})
        expect(res).to be dataset
      end
    end

    context 'with faculty param' do
      it 'filters semesters by faculty id' do
        res = filter.filter(dataset, {faculty: 18000})
        expect(res.sql).to include '"faculty" = 18000'
      end
    end
  end
end
