require 'models/parallel'
require 'pg'
require 'sequel/extensions/core_refinements'

class Person < Sequel::Model
  using Sequel::CoreRefinements

  # FIXME: this should be put somewhere else so we don't have dependency on other model
  #        see also ApiHelper#user_allowed?
  def self.teacher?(username)
    DB.select(1)
      .where(Parallel.where(:teacher_ids.pg_array.contains([username])).exists)
      .any?
  end

  def self.id_from_token(token)
    begin
      self.where(access_token: token).get(:id)
    rescue Sequel::DatabaseError => err
      # return nil if token is malformed UUID
      raise err unless err.wrapped_exception.is_a? PG::InvalidTextRepresentation
    end
  end
end
