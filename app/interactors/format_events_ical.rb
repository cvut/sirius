require 'role_playing'
require 'interpipe/interactor'
require 'icalendar'

##
# Converts {Event}'s collection to an ICalendar.
#
class FormatEventsIcal
  include RolePlaying::Context
  include Interpipe::Interactor

  def setup
    @calendar = Icalendar::Calendar.new
  end

  ##
  # Adds events to an ICalendar and convert it to a text representation.
  # @return [String] ICalendar as a string.
  def perform(events: [])
    @events = Array(events)

    @events.each do |e|
      @calendar.add_event IcalEvent(e).to_ical
    end
  end

  def results
    {ical: ical}
  end

  def ical
    @calendar.to_ical
  end


  # Event to Icalendar::Event mapping.
  role :IcalEvent do

    # Maps {Event} attributes to {Icalendar::Event} object.
    # @return [Icalendar::Event]
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
