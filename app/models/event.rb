class Event < Sequel::Model

  many_to_one :room

  def period
    Sirius::Period.new(starts_at, ends_at)
  end

  def period=(new_period)
    self.starts_at = new_period.starts_at
    self.ends_at = new_period.ends_at
  end

end
