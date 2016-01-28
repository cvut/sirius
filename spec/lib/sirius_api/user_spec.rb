require 'spec_helper'
require 'rspec-parameterized'
require 'sirius_api/user'
require 'sirius_api/scopes'

module SiriusApi
  describe User do

    using RSpec::Parameterized::TableSyntax

    subject(:user) { described_class.new('rubyeli', scope, umapi_client: umapi_client) }
    let(:umapi_client) { double('UmapiClient') }
    let(:scope) { [] }

    describe '#has_any_role?' do

      let(:roles) { ['B-18000-ZAMESTNANEC', 'B-0000-DEKAN'] }

      context 'when username is not nil' do
        let(:umapi_result) { false }

        before do
          expect( umapi_client ).to receive(:user_has_roles?).once
            .with(user.username, roles, operator: :any)
            .and_return(umapi_result)
        end

        where :desc       , :expected do
          'positive case' | true
          'negative case' | false
        end
        with_them ->{ desc } do
          let(:umapi_result) { expected }

          it "returns #{row.expected}" do
            expect( user.has_any_role?(*roles) ).to be expected
          end

          it 'caches already decided roles' do
            3.times { expect( user.has_any_role?(*roles) ).to be expected }
          end
        end
      end

      context 'when username is nil' do
        subject(:user) { User.new(nil) }

        # Should not call umapi_client at all.
        it { expect { user.has_any_role?(*roles) }.to raise_error(StandardError) }
      end
    end

    describe '#student_access_allowed?' do
      context 'with READ_ALL scope' do
        let(:scope) { ['cvut:sirius:all:read'] }

        it 'allows student listing' do
          expect(user.student_access_allowed?).to be_truthy
        end
      end

      context 'with limited scope' do
        let(:scope) { ['cvut:sirius:personal:read'] }

        it 'disallows student listing' do
          expect(user.student_access_allowed?).to be_falsey
        end
      end
    end
  end
end
