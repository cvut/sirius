class Token < Sequel::Model
  def self.authenticate(token_id)
    token = self.with_pk!(token_id)
  rescue
    nil
  else
    token.username
  end
end
