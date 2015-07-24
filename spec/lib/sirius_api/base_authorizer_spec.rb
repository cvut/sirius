require 'spec_helper'
require 'sirius_api/base_authorizer'

describe SiriusApi::BaseAuthorizer do

    let(:authorizer_class) {
      Class.new(SiriusApi::BaseAuthorizer) do
        scope 'foo' do
          permit :get, '/bar'
        end
      end
    }
    subject(:authorizer) { authorizer_class.new('vomackar') }

  describe '.scope' do
    it 'supports defining rules on class level' do
      expect(authorizer_class.scope_registry).to include 'foo'
    end
  end

  describe '#authorize_request!' do
    it 'allows described request' do
      expect { authorizer.authorize_request!(['baz', 'foo'], :get, '/bar') }.not_to raise_error
    end

    it 'rejects non-matching request by URL' do
      expect { authorizer.authorize_request!(['baz', 'foo'], :get, '/boo') }.to raise_error(SiriusApi::Errors::Authorization)
    end

    it 'rejects non-matching request by scope' do
      expect { authorizer.authorize_request!(['baz'], :get, '/bar') }.to raise_error(SiriusApi::Errors::Authorization)
    end

    it 'rejects non-matching request by method' do
      expect { authorizer.authorize_request!(['foo'], :post, '/bar') }.to raise_error(SiriusApi::Errors::Authorization)
    end
  end
end
