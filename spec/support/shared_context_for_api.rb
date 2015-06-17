shared_context 'API response' do
  subject { response }
  let(:status) { response.status }
  let(:body) { response.body }
  let(:headers) { response.headers }
end

shared_context 'authenticated user', authenticated: true do
  let(:username) { 'user' }
  let(:token) { Fabricate(:token, username: username) }
  let(:access_token) { { access_token: token.uuid } }

  def auth_get(path, **params)
    get path, params.merge(access_token)
  end
end
