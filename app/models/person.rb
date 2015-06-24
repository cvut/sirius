require 'models/parallel'

class Person < Sequel::Model

  # FIXME: this should be put somewhere else so we don't have dependency on other model
  #        see also ApiHelper#user_allowed?
  def self.teacher?(username)
    teacher_ids = Sequel.pg_array(:teacher_ids)
    DB.select(1)
      .where(Parallel.where(teacher_ids.contains([username])).exists)
      .any?
  end
end
