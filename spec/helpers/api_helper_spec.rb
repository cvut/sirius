require 'spec_helper'
require 'helpers/api_helper'
require 'hashie'

describe ApiHelper do

  subject(:helper) { Class.new { extend ApiHelper } }

  describe '#user_allowed?' do
    let(:auth_scope) { '*' }
    before do
      allow(helper).to receive(:auth_scope).and_return(auth_scope)
    end
    context 'standard user' do
      let(:auth_scope) { 'vomackar' }

      it 'grants authorization for matching username' do
        expect(helper.user_allowed? 'vomackar').to be true
      end

      it 'prevents authorization for different username' do
        expect(helper.user_allowed? 'skocdopet').to be false
      end
    end

    context 'superuser' do
      let(:auth_scope) { '*' }

      it 'grants authorization to all users' do
        expect(helper.user_allowed? 'vomackar').to be true
      end
    end
  end
end
