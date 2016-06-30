require 'spec_helper'
require 'interactors/update_parallel_students'

describe UpdateParallelStudents do

  describe '#perform' do

    subject(:update) { described_class }
    let(:parallel) { double(:parallel, save: nil, :student_ids= => nil).as_null_object }
    let(:kosapi_student) { double(:kosapi_student, username: 'foo', full_name: 'Mr. Foo Bar') }

    it 'updates parallel students' do
      expect(parallel).to receive(:student_ids=).with(['foo'])
      update.perform(students: {parallel => [kosapi_student]})
    end

    it 'sets results' do
      results = update.perform(students: {parallel => [kosapi_student]}).results
      expect(results[:people].size).to eq 1
    end

    it 'converts students' do
      results = update.perform(students: {parallel => [kosapi_student]}).results
      converted_student = results[:people].first
      expect(converted_student.id).to eq 'foo'
      expect(converted_student.full_name).to eq 'Mr. Foo Bar'
    end

    context 'with students without username' do
      let(:kosapi_student) { double(:kosapi_student, username: nil, personal_number: 1234, full_name: 'Mr. Foo Bar') }

      it 'uses students personal number as id' do
        results = update.perform(students: {parallel => [kosapi_student]}).results
        converted_student = results[:people].first
        expect(converted_student.id).to eq '1234'
      end
    end

  end

end
