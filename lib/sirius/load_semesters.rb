require 'corefines'
require 'date_refinements'
require 'models/semester_period'
require 'models/faculty_semester'
require 'yaml'

using Corefines::Hash[:except, :rekey, :symbolize_keys]
using Corefines::Object::instance_values
using ::DateRefinements


def parse_day_name(str)
  Date.strptime(str, '%A').wday rescue fail "Invalid day name: #{str}"
end

def parse_parity(value)
  case value
  when String, Symbol
    value = value.downcase.to_sym
    return value if value && [:even, :odd].include?(value)
  when Integer
    return value % 2 == 0 ? :even : :odd
  end
  fail "Invalid parity: #{value}, expected 'even' / 0, or 'odd' / 1"
end

def parity_num(parity)
  case parity
  when :even then 0
  when :odd then 1
  else fail "Invalid parity: #{parity}"
  end
end

def resolve_parity(base_date, parity, new_date)
  weeks_since_base = ((new_date.start_of_week - base_date.start_of_week) / 7).abs.floor
  parse_parity((weeks_since_base + parity_num(parity)) % 2)
end


class Period
  attr_reader :starts, :ends, :type

  def initialize(starts: nil, ends: nil, date: nil, **rest)
    starts = ends = date if date
    fail "starts must be a Date, given: #{starts}" unless starts.is_a? Date
    fail "ends must be a Date, given: #{ends}" unless ends.is_a? Date

    @starts = starts.freeze
    @ends = ends.freeze
    freeze
  end

  def with(**attrs)
    if attrs != instance_values
      self.class.new(**instance_values.merge(attrs))
    else
      self
    end
  end
end

class ExamsPeriod < Period
  def initialize(**rest)
    @type = :exams
    super **rest
  end
end

class TeachingPeriod < Period
  attr_reader :parity

  def initialize(parity:, **rest)
    @parity = parse_parity(parity).freeze
    @type = :teaching
    super **rest
  end
end

class IrregularTeachingPeriod < TeachingPeriod
  attr_reader :day

  def initialize(day:, **rest)
    day = parse_day_name(day) if day.is_a? String
    @day = day if day
    super **rest
  end
end

class HolidayPeriod < Period
  attr_reader :name

  def initialize(name:, **rest)
    @name = name.freeze  # TODO
    @type = :holiday
    super **rest
  end
end


def align_periods(data)
  # Maps data to array of periods sorted by the type and starts|date.
  periods = {
    'teaching' => TeachingPeriod,
    'exams' => ExamsPeriod,
    'holidays' => HolidayPeriod,
    'irregulars' => IrregularTeachingPeriod,
  }.flat_map do |key, constr|
    data.fetch(key, [])
        .map(&:symbolize_keys)
        .sort_by { |h| h[:starts] || h[:date] }
        .map { |h| constr.new(**h) }
  end

  periods_by_day = periods.reduce({}) do |days, period|
    period.starts.upto(period.ends).map do |date|
      days[date] = period
    end
    days
  end

  periods_by_day
    .sort  # sort by key (day)
    .slice_when { |(_, a), (_, b)| a != b }  # group identical continuous periods
    .map do |slice|
      period = slice.first.last
      slice_starts, slice_ends = slice.first.first, slice.last.first

      # Shrink period and shift parity if needed.
      attrs = { starts: slice_starts, ends: slice_ends }
      if period.starts != slice_starts && period.respond_to?(:parity)
        attrs[:parity] = resolve_parity(period.starts, period.parity, slice_starts)
      end
      period.with(**attrs)
    end.to_a
end

def validate_periods!(periods, sem_starts, sem_ends)
  if periods.none? { |p| p.is_a? TeachingPeriod }
    fail 'No teaching period found!'
  end

  if periods.first.starts < sem_starts
    fail "First period starts before the semester (#{periods.first.starts} < #{sem_starts}!"
  end

  if periods.last.ends > sem_ends
    fail "Last periods ends after the semester (#{periods.last.ends} > #{sem_ends})!"
  end

  periods.each_cons(2) do |p1, p2|
    if (p1.ends + 1) != p2.starts
      fail "Periods are not continuous! There's a gap between #{p1.ends} and #{p2.starts}."
    end
  end

  periods
end

def create_semester_period(period)
  attrs = period.instance_values
    .rekey(
      :starts => :starts_at,
      :ends => :ends_at,
      :parity => :first_week_parity,
      :day => :first_day_override)
  attrs[:irregular] = true if period.is_a? IrregularTeachingPeriod

  SemesterPeriod.new(**attrs)
end

input = YAML.load_file('data/semesters/B171.yml')

input.each do |sem, sem_data|
  sem_data.except('holidays').each do |faculty, faculty_data|
    next if faculty != 13000

    faculty_data['holidays'] ||= {}
    faculty_data['holidays'].concat(sem_data.fetch('holidays', {}))

    sem_starts, sem_ends = faculty_data['semester'].fetch_values('starts', 'ends')

    periods = align_periods(faculty_data)
    validate_periods! periods, sem_starts, sem_ends

    periods.each do |p|
      puts DB[SemesterPeriod.table_name].insert_sql(create_semester_period(p).to_hash)
    end
  end
end
