require 'spec_helper'
require 'teacher_change_schedule_exception'

describe TeacherChangeScheduleException do

  subject(:exception) do
    described_class.new(options: Sequel.hstore(teacher_ids: '{skocpet,vomackar}'))
  end
  let(:event) { Fabricate.build(:event, teacher_ids: %w(dude)) }

  describe '#apply_people_assign' do
    it 'changes teacher_ids' do
      expect {
        exception.apply_people_assign(event)
      }.to change(event, :teacher_ids).from(%w(dude)).to(%w(skocpet vomackar))
    end

    it 'validates username list format' do
      exception.options = Sequel.hstore(teacher_ids: '{invalid format,')
      expect { exception.apply_people_assign(event) }.to raise_error(RuntimeError)
    end
  end
end
