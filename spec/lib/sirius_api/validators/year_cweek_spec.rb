require 'api_spec_helper'
require 'sirius_api/validators/year_cweek'

describe SiriusApi::Validators::YearCweek do

  module YearCweekSpec
    class API < Grape::API
      default_format :json
      params { requires :cweek, year_cweek: true }
      get {}
    end
  end

  def app
    YearCweekSpec::API
  end

  context 'invalid input' do
    it 'refuses non-existent week number' do
      get '/', cweek: '2000-99'
      expect(last_response.status).to eq 400
    end

    it 'refuses invalid format' do
      get '/', cweek: '99-22'
      expect(last_response.status).to eq 400
    end
  end

  context 'valid input' do
    it 'accepts valid year-cweek' do
      get '/', cweek: '2016-42'
      expect(last_response.status).to eq 200
    end
  end
end
