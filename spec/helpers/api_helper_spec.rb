require 'spec_helper'
require 'helpers/api_helper'
describe ApiHelper do
  subject(:helper) { Class.new { extend ApiHelper } }

  describe '#user_allowed?' do
    WardenMock = Struct.new(:user)
    let(:auth_user) { '*' }
    before do
      allow(helper).to receive(:env) { {'warden' => WardenMock.new(auth_user)} }
    end
    context 'standard user' do
      let(:auth_user) { 'vomackar' }

      it 'grants authorization for matching username' do
        expect(helper.user_allowed? 'vomackar').to be true
      end

      it 'prevents authorization for different username' do
        expect(helper.user_allowed? 'skocdopet').to be false
      end
    end
  end

end
