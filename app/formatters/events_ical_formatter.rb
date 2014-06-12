require 'icalendar'
require 'roles/event/to_ical'
class EventIcalFormatter
  def self.call(events = [])
    new.add_events(events).to_ical
  end

  def initialize
    @calendar = Icalendar::Calendar.new
  end

  def add_events(events = [])
    Array(events).each do |e|
      @calendar.add_event Roles::Event::ToIcal.new(e).to_ical
    end
  end

  def to_ical
    @calendar.to_ical
  end

end
