require 'spec_helper'
require 'ostruct'
require 'sirius_api/scopes'
require 'sirius_api/strategies/remote_oauth_server'

describe SiriusApi::Strategies::RemoteOAuthServer do

  subject(:strategy) { described_class.new(env) }

  let(:env) { { 'warden' => OpenStruct.new(errors: Warden::Proxy::Errors.new) }  }

  before do
    allow(strategy).to receive(:params) { { 'access_token' => access_token }}
    allow(strategy).to receive(:request_token_info) { token_info }
  end

  describe '#authenticate!' do
    before { strategy.authenticate! }

    let(:access_token) { '123456' }

    let(:token_info) do
      OpenStruct.new(status: status, client_id: client_id, exp: exp,
                     scope: scope, user_name: user_name)
    end
    let(:status) { 200 }
    let(:client_id) { 'foo' }
    let(:exp) { Time.now + 1.hour }
    let(:scope) { ['urn:some:other:scope', SiriusApi::Scopes::READ_ALL].flatten }
    let(:user_name) { nil }

    shared_examples 'successful authentication' do
      it 'succeeds the authentication' do
        expect(strategy.result).to be_truthy
      end

      it 'does not add an error message' do
        expect(strategy.errors).to be_empty
      end
    end

    shared_examples 'failed authentication' do
      it 'fails the authentication' do
        expect(strategy.result).to be_falsey
      end

      it 'adds an error message' do
        expect(strategy.errors).not_to be_empty
      end
    end

    context 'non-existing access token' do
      let(:access_token) { nil }
      it_behaves_like 'failed authentication'
    end

    context 'invalid access token' do
      let(:status) { 400 }
      it_behaves_like 'failed authentication'
    end

    context 'expired access token' do
      let(:exp) { Time.now - 1.hour }
      it_behaves_like 'failed authentication'
    end

    context 'OAAS error' do
      let(:status) { 500 }
      it_behaves_like 'failed authentication'
    end

    context 'invalid response from check_token' do

      context 'missing client_id' do
        let(:client_id) { nil }
        it_behaves_like 'failed authentication'
      end

      context 'missing exp' do
        let(:exp) { nil }
        it_behaves_like 'failed authentication'
      end

      context 'empty scope' do
        let(:scope) { [] }
        it_behaves_like 'failed authentication'
      end
    end

    context 'with valid token' do
      it_behaves_like 'successful authentication'
    end
  end
end
