class Period

  attr_reader :starts_at, :ends_at

  def initialize(starts_at, ends_at)

    @starts_at = starts_at
    @ends_at = ends_at
  end


  def ==(other)
    @starts_at == other.starts_at && @ends_at == other.ends_at
  end

  def self.parse(start_str, end_str)
    Period.new(Time.parse(start_str), Time.parse(end_str))
  end


  # Checks if other period is inside this period.
  #
  # This means that both starts_at and ends_at of other
  # period have to be included in this period.
  #
  def include?(other_period)
    inside?(other_period.starts_at) && inside?(other_period.ends_at)
  end

  # Checks if other period overlaps with this period.
  #
  # Returns true when either other_period.starts_at
  # or other_period.ends_at is included this period.
  #
  def cover?(other_period)
    inside?(other_period.starts_at) || inside?(other_period.ends_at)
  end

  alias_method :intersect?, :cover?
  alias_method :overlap?, :cover?

  private
  def inside?(date)
    start_check = end_check = true
    start_check = (starts_at <= date) if starts_at
    end_check = (date <= ends_at) if ends_at
    start_check && end_check
  end

end
