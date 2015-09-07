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

    let(:access_token) { '123456'}
    let(:token_info) { OpenStruct.new(status: status, client_id: client_id, scope: scope, user_id: user_id) }
    let(:status) { 200 }
    let(:client_id) { 'foo' }
    let(:scope) { ['urn:some:other:scope', SiriusApi::Scopes::READ_ALL].flatten }
    let(:user_id) { nil }

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

    context 'missing access token' do
      let(:status) { 404 }
      it_behaves_like 'failed authentication'
    end

    context 'non-existing access token' do
      let(:access_token) { nil }
      it_behaves_like 'failed authentication'
    end

    context 'OAAS error' do
      let(:status) { 500 }
      it_behaves_like 'failed authentication'
    end

    context 'invalid OAAS response' do
      let(:client_id) { nil }
      it_behaves_like 'failed authentication'
    end

    context 'empty scope' do
      let(:scope) { [] }
      it_behaves_like 'failed authentication'
    end

    context 'with limited scope' do
      let(:scope) { SiriusApi::Scopes::READ_LIMITED }

      context 'and valid flow' do
        let(:user_id) { 'skocdopet' }
        it_behaves_like 'successful authentication'
      end

      context 'and invalid flow' do
        it_behaves_like 'failed authentication'
      end
    end

    context 'with valid token' do
      it_behaves_like 'successful authentication'
    end
  end
end
