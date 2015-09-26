shared_context 'API response' do
  subject { response }
  let(:status) { response.status }
  let(:body) { response.body }
  let(:headers) { response.headers }
end

shared_context 'authenticated user via local token', authenticated: true do

  let(:username) { 'user' }
  let(:token) { Fabricate(:token, username: username) }
  let(:access_token) { token.uuid }

  def auth_get(path, **params)
    get path, params.merge(access_token: access_token)
  end
end

shared_context 'authenticated via oauth', authenticated: :oauth do
  let(:access_token) { retrieve_oauth_token }

  def auth_get(path, **params)
    get path, params.merge(access_token: access_token)
  end

  def infer_cassette_name
    group_descriptions = []
    klass = self

    while klass.respond_to?(:metadata) && klass.metadata
      group_descriptions << klass.metadata[:example_group][:description]
      klass = klass.superclass
    end

    group_descriptions.compact.reverse.join('/')
  end

  def retrieve_oauth_token
    client = Faraday.new do |c|
      c.response :json, content_type: /\bjson$/
      c.request  :url_encoded
      c.adapter Faraday.default_adapter
    end
    client.basic_auth(Config.kosapi_oauth_client_id, Config.kosapi_oauth_client_secret)
    resp = client.post(Config.oauth_token_uri, { 'grant_type' => 'client_credentials' })
    resp.body['access_token']
  end
end
