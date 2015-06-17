shared_examples 'invalid endpoint' do
  context 'for authenticated user', authenticated: true do
    it 'returns a Not Found error' do
      get path_for(path)
      expect(response.status).to eql 404
    end
  end
end

shared_examples 'non-existent resource' do
  context 'for authenticated user', authenticated: true do
    before { auth_get path_for(path) }
    it 'returns a 404 Not Found error' do
      expect(status).to eql(404)
    end
    it 'returns a meaningful message' do
      expect(body).to be_json_eql('"Resource not found"').at_path('message')
    end
  end
end

shared_examples 'forbidden resource' do
  context 'for authenticated user', authenticated: true do
    before { auth_get path_for(path) }
    it 'returns a 403 Frobidden error' do
      expect(status).to eql(403)
    end
  end
end
