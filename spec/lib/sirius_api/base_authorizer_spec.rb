require 'spec_helper'
require 'sirius_api/base_authorizer'
require 'sirius_api/user'

describe SiriusApi::BaseAuthorizer do

    let(:scope) { ['baz', 'foo'] }
    let(:user) { SiriusApi::User.new('skocdopet', scope) }
    let(:authorizer_class) do
      Class.new(SiriusApi::BaseAuthorizer) do
        scope 'foo', 'bar' do
          permit :get, '/bar'
        end

        scope 'foo' do
          permit :post, '/baz'
        end

        scope 'urn:baz' do
          permit :delete, '/42'
        end
      end
    end

    subject(:authorizer) { authorizer_class.new(user) }

  describe '.scope' do
    it 'supports defining rules on class level' do
      expect(authorizer_class.scope_registry).to include('foo', 'bar', 'urn:baz')
    end
  end

  describe '#authorize_request!' do
    it 'allows described request' do
      expect { authorizer.authorize_request!(:get, '/bar') }.not_to raise_error
    end

    it 'rejects non-matching request by URL' do
      expect { authorizer.authorize_request!(:get, '/boo') }.to raise_error(SiriusApi::Errors::Authorization)
    end

    it 'rejects non-matching request by scope' do
      user.scopes = ['urn:baz']
      expect { authorizer.authorize_request!(:get, '/bar') }.to raise_error(SiriusApi::Errors::Authorization)
    end

    it 'rejects non-matching request by method' do
      user.scopes = ['foo']
      expect { authorizer.authorize_request!(:post, '/bar') }.to raise_error(SiriusApi::Errors::Authorization)
    end

    it 'works with multiple scopes for single rule' do
      user.scopes = ['bar']
      expect { authorizer.authorize_request!(:get, '/bar') }.not_to raise_error
    end

    it 'allows multiple definition blocks for single scope' do
      user.scopes = ['foo']
      expect { authorizer.authorize_request!(:post, '/baz') }.not_to raise_error
    end
  end
end
