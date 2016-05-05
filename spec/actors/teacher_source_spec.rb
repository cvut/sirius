require 'spec_helper'
require 'actors/teacher_source'

describe TeacherSource do
  include ActorHelper

  let(:semester) { Fabricate(:faculty_semester) }
  let!(:event) do
    Fabricate(:event, teacher_ids: ['vomackar'], semester: semester.code, faculty: semester.faculty)
  end
  subject(:actor) { described_class.new(nil, semester) }

  describe '#load_teachers' do
    it 'loads teacher usernames with at least one event in semester' do
      expect(actor.load_teachers).to contain_exactly 'vomackar'
    end
  end
end
