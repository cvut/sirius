require 'spec_helper'
require 'models/token'
describe Token do
  describe '.authenticate' do
    subject(:authenticated) { Token.authenticate('2054f3e4-d3e6-4c97-b2e9-7d2dd8043f90') }
    context 'for unassociated token' do
      it { should be_nil }
    end
    context 'for a valid token' do
      before do
        expect(Token).to receive(:with_pk) { Fabricate.build(:token, username: 'kordikp') }
      end
      it 'returns a username associated with the token' do
        expect(authenticated).to eql 'kordikp'
      end
    end
    context 'for invalid token format' do
      it 'returns nil' do
        expect(Token.authenticate('11111111-1111-1111-9999-888888888888')).to be_nil
      end
    end
  end
end
