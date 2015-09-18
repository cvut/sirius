require 'spec_helper'
require 'sirius_api/people_authorizer'
require 'sirius_api/user'
require 'sirius_api/scopes'

describe SiriusApi::PeopleAuthorizer do

  let(:scope) { SiriusApi::Scopes::READ_PERSONAL }
  let(:user) { SiriusApi::User.new('ALICE', scope) }
  subject(:authorizer) { described_class.new(user) }

  describe '#authorize_request!' do

    {
      'READ_PERSONAL' => SiriusApi::Scopes::READ_PERSONAL,
      'READ_LIMITED' => SiriusApi::Scopes::READ_LIMITED
    }.each do |scope_name, scope_arr|
      context "for #{scope_name} scope" do
        let(:scope) {scope_arr}
        it 'allows request to personal endpoint' do
          expect {
            authorizer.authorize_request!(:get, '/people/:username', {username: 'ALICE'})
          }.not_to raise_error
        end

        it 'denies request to endpoint for other user' do
          expect {
            authorizer.authorize_request!(:get, '/people/:username', {username: 'BOB'})
          }.to raise_error(SiriusApi::Errors::Authorization)
        end

        it 'denies request to the index endpoint' do
          expect {
            authorizer.authorize_request!(:get, '/people')
          }.to raise_error(SiriusApi::Errors::Authorization)
        end
      end
    end


    context 'for READ_ALL scope' do
      let(:scope) { SiriusApi::Scopes::READ_ALL }

      it 'allows request to individual endpoints' do
        expect {
          authorizer.authorize_request!(:get, '/people/:username', {username: 'BOB'})
        }.not_to raise_error
      end

      it 'allows request to index endpoint' do
        expect { authorizer.authorize_request!(:get, '/people') }.not_to raise_error
      end
    end
  end
end
