RSpec.shared_context 'API response' do
  subject { response }
  let(:status) { response.status }
  let(:body) { response.body }
  let(:headers) { response.headers }
end
