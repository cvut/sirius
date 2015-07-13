require 'spec_helper'
require 'sirius_api/umapi_client'

describe SiriusApi::UmapiClient, :vcr do

  describe '#request_user_info' do
    it 'retrieves user info from umapi' do
      res = subject.request_user_info('szolatib')
      expect(res.username).to eq 'szolatib'
    end
  end
end
