require 'spec_helper'
require 'helpers/api_helper'
require 'hashie'

describe ApiHelper do

  subject(:helper) { Class.new { extend ApiHelper } }

  describe '#user_allowed?' do
    let(:auth_user) { '*' }
    before do
      allow(helper).to receive(:auth_user).and_return(auth_user)
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

    context 'superuser' do
      let(:auth_user) { '*' }

      it 'grants authorization to all users' do
        expect(helper.user_allowed? 'vomackar').to be true
      end
    end
  end

  describe '#paginate' do

    let(:dataset) { Sequel.mock.dataset.from(:test) }
    let(:params) { {limit: 2, offset: 1} }

    before do
      allow(helper).to receive(:params).and_return Hashie::Mash.new(params)
    end

    it "sets limit and offset from the #params" do
      expect(helper.paginate(dataset).opts).to include params
    end

    it "sets :total_count option with the result of #count before setting the limit" do
      expect(dataset).to receive(:count).ordered.and_return 42
      expect(dataset).to receive(:limit).ordered.and_call_original

      expect(helper.paginate(dataset).opts).to include({total_count: 42})
    end
  end

end
