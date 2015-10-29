require 'spec_helper'
require 'sirius_api/umapi_client'

describe SiriusApi::UmapiClient, :vcr do

  subject(:client) { described_class.new }
  let(:username) { 'szolatib' }
  let(:status) { 200 }
  let(:token) { double(status: status).as_null_object }

  describe '#user_has_roles?' do

    before do
      allow(client).to receive(:token) { token }
    end

    context 'with blank username' do
      it 'raises ArgumentError' do
        [nil, '', '  '].each do |username|
          expect { client.user_has_roles? username, ['FOO'] }.to raise_error(ArgumentError)
        end
      end
    end

    context 'with empty roles' do
      it 'raises ArgumentError' do
        [nil, [], Set.new].each do |roles|
          expect { client.user_has_roles? username, roles }.to raise_error(ArgumentError)
        end
      end
    end

    context 'with invalid operator' do
      it 'raises ArgumentError' do
        expect {
          client.user_has_roles? username, ['FOO'], operator: 'xyz'
        }.to raise_error(ArgumentError)
      end
    end



    context 'with 200 status' do
      let(:status) { 200 }

      it 'checks whether user has a role assigned' do
        expect(client.user_has_roles?(username, ['B-00000-ZAMESTNANEC'])).to be_truthy
      end

      it 'checks whether user has ALL of multiple roles assigned (positive case)' do
        expect(client.user_has_roles?(username, ['B-00000-ZAMESTNANEC', 'B-18000-ZAMESTNANEC'])).to be_truthy
      end

      it 'checks whether user has ANY roles (positive case)' do
        expect(client.user_has_roles?(username, ['NOT-A-ROLE', 'B-18000-ZAMESTNANEC'], operator: 'any')).to be_truthy
      end

      it 'checks whether user has NONE of multiple roles assigned (positive case)' do
        expect(client.user_has_roles?(username, ['NOT-A-ROLE', 'X-FOO-BAR'], operator: 'none')).to be_truthy
      end
    end

    context 'with 404 status' do
      let(:status) { 404 }

      it 'checks whether user has a role not assigned' do
        expect(client.user_has_roles?(username, ['X-FOO-BAR'])).to be_falsey
      end

      it 'checks whether user has ALL of multiple roles (negative case)' do
        expect(client.user_has_roles?(username, ['NOT-A-ROLE', 'B-18000-ZAMESTNANEC'])).to be_falsey
      end

      it 'checks whether user has ANY roles (negative case)' do
        expect(client.user_has_roles?(username, ['NOT-A-ROLE', 'X-FOO-BAR'], operator: 'any')).to be_falsey
      end

      it 'checks whether user has NONE of multiple roles assigned (negative case)' do
        expect(client.user_has_roles?(username, ['B-00000-ZAMESTNANEC', 'X-FOO-BAR'], operator: 'none')).to be_falsey
      end
    end

    context 'with unexpected status' do
      let(:status) { 500 }

      it 'raises an error' do
        expect{ client.user_has_roles?(username, ['A-ROLE']) }.to raise_error(RuntimeError)
      end
    end
  end
end
