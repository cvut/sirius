class Person < Sequel::Model

  def self.teacher?(username)
    teacher_ids = Sequel.pg_array(:teacher_ids)
    DB.select(1)
      .where(Parallel.where(teacher_ids.contains([username])).exists)
      .any?
  end
end
