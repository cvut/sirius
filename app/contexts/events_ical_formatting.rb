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
        e.start = starts_at.strftime("%Y%m%dT%H%M%S")
        e.end = ends_at.strftime("%Y%m%dT%H%M%S")
        e.location = '' # FIXME!
        e.klass = 'PUBLIC'
        e.created = e.created_at
        e.last_modified = self.updated_at
        #e.uid = e.url = "/events/#{self.id}" # FIXME!
        #e.add_comment()
      end
    end
  end

end
