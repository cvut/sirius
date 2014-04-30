module API
  class SampleEndpoint < Grape::API
    get 'foo' do
      {foo: 'bar'}
    end
  end
end
