require 'models/parallel'
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
end
