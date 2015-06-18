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


shared_examples 'paginated resource' do

  subject { body }

  context 'with default offset and limit' do
    let(:meta) do
      {
        limit: ApiHelper::DEFAULT_LIMIT,
        offset: ApiHelper::DEFAULT_OFFSET,
        count: total_count
      }
    end

    before { auth_get path }

    it 'returns OK' do
      expect(status).to eql 200
    end

    it { should have_json_size(meta.count).at_path(json_type) }
    it { should be_json_eql(meta.to_json).at_path('meta') }
  end

  context 'with offset and limit' do
    let(:meta) do
      {
        limit: 1,
        offset: 1,
        count: total_count
      }
    end

    before { auth_get "#{path}?limit=1&offset=1" }

    it { should have_json_size(1).at_path(json_type) }
    it { should be_json_eql(meta.to_json).at_path('meta') }
  end

  context 'with invalid value' do

    before { auth_get "#{path}?offset=asdasd" }

    it 'returns an error' do
      expect(response.status).to eql 400
    end

    context 'for invalid integer' do

      it 'returns an error for zero limit' do
        auth_get "#{path}?limit=0"
        expect(response.status).to eql 400
      end

      it 'returns an error for invalid (negative) offset' do
        auth_get "#{path}?offset=-1"
        expect(response.status).to eql 400
      end
    end
  end
end
