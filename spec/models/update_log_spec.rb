require 'spec_helper'
require 'models/update_log'

describe UpdateLog do

  describe '.last_partial_update' do

    it 'returns last partial update from DB' do
      Fabricate.times(4, :update_log)
      last_created_log = Fabricate(:update_log)
      last_found_log = UpdateLog.last_partial_update
      expect(last_found_log).to eq last_created_log
    end

  end

end
