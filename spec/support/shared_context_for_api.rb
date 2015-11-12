shared_context 'API response' do
  subject { response }
  let(:status) { response.status }
  let(:body) { response.body }
  let(:headers) { response.headers }
end

shared_context 'authenticated user via local token', authenticated: true do

  let(:person) { Fabricate(:person) }
  let(:access_token) { person.access_token }

  def auth_get(path, **params)
    get path, params.merge(access_token: access_token)
  end
end
