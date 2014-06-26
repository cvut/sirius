require 'icalendar'
require 'role_playing'

class EventsIcalFormatting
  include RolePlaying::Context

  def initialize(events)
    @events = Array(events) # Always work with collection
    @calendar = Icalendar::Calendar.new
  end

  def call
    @events.each do |e|
      @calendar.add_event IcalEvent(e).to_ical
    end
    @calendar.to_ical
  end

  role :IcalEvent do
    def to_ical
      ical_event = Icalendar::Event.new.tap do |e|
        e.summary = name
        e.description = note
        e.dtstart = starts_at.strftime("%Y%m%dT%H%M%S")
        e.dtend = ends_at.strftime("%Y%m%dT%H%M%S")
        e.location = '' # FIXME!
        e.ip_class = 'PUBLIC'
        e.created = self.created_at
        e.last_modified = self.updated_at
        #e.uid = e.url = "/events/#{self.id}" # FIXME!
        #e.add_comment()
      end
    end
  end

end
