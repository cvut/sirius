require 'models/token'
require 'securerandom'
Fabricator(:token) do
  uuid { SecureRandom.uuid }
  username 'kordikp'
  last_used_at Time.now
end
