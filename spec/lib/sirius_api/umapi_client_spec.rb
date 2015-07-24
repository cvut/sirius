require 'spec_helper'
require 'sirius_api/umapi_client'

describe SiriusApi::UmapiClient, :vcr do

  let(:username) { 'szolatib' }

  describe '#request_user_info' do
    it 'retrieves user info from umapi' do
      res = subject.request_user_info(username)
      expect(res.username).to eq username
    end
  end

  describe '#user_has_roles?' do
    it 'checks whether user has a role assigned' do
      expect(subject.user_has_roles?(username, ['B-00000-ZAMESTNANEC'])).to be_truthy
    end

    it 'checks whether user has a role not assigned' do
      expect(subject.user_has_roles?(username, ['X-FOO-BAR'])).to be_falsey
    end

    it 'checks whether user has ALL of multiple roles assigned (positive case)' do
      expect(subject.user_has_roles?(username, ['B-00000-ZAMESTNANEC', 'B-18000-ZAMESTNANEC'])).to be_truthy
    end

    it 'checks whether user has ALL of multiple roles (negative case)' do
      expect(subject.user_has_roles?(username, ['NOT-A-ROLE', 'B-18000-ZAMESTNANEC'])).to be_falsey
    end

    it 'checks whether user has ANY roles (positive case)' do
      expect(subject.user_has_roles?(username, ['NOT-A-ROLE', 'B-18000-ZAMESTNANEC'], operator: 'any')).to be_truthy
    end

    it 'checks whether user has ANY roles (negative case)' do
      expect(subject.user_has_roles?(username, ['NOT-A-ROLE', 'X-FOO-BAR'], operator: 'any')).to be_falsey
    end

    it 'checks whether user has NONE of multiple roles assigned (positive case)' do
      expect(subject.user_has_roles?(username, ['NOT-A-ROLE', 'X-FOO-BAR'], operator: 'none')).to be_truthy
    end

    it 'checks whether user has NONE of multiple roles assigned (negative case)' do
      expect(subject.user_has_roles?(username, ['B-00000-ZAMESTNANEC', 'X-FOO-BAR'], operator: 'none')).to be_falsey
    end
  end
end
