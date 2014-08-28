require 'role_playing'
require 'interpipe/interactor'
require 'icalendar'
require 'icalendar/tzinfo'

##
# Converts {Event}'s collection to an ICalendar.
#
class FormatEventsIcal
  include RolePlaying::Context
  include Interpipe::Interactor

  def setup
    @calendar = Icalendar::Calendar.new
    @calendar.add_timezone timezone(Config.tz)
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

  def timezone(tzid)
    tz = TZInfo::Timezone.get(tzid)
    tz.ical_timezone(DateTime.new 2014) # XXX it needs _some_ date; maybe current year should be used instead?
  end

  def results
    {ical: ical}
  end

  def ical
    @calendar.to_ical
  end


  # Event to Icalendar::Event mapping.
  role :IcalEvent do

    def ical_summary
      # FIXME: Add localized #{event_type}
      "#{course_id} #{sequence_number}. #{localized_event_type} (#{parallel})"
    end

    def ical_description
      # Programování v Ruby (prof. Petr Skočdopole PhD., Ing. Karel Vomáčka)
      # TODO: remove hardcoded locale, map usernames
      # XXX: I don't like this chaining in particular; could we get some role or helper method?
      "#{course.name['cs']}"
    rescue
      nil
    end

    # Maps {Event} attributes to {Icalendar::Event} object.
    # @return [Icalendar::Event]
    def to_ical
      Icalendar::Event.new.tap do |e|
        e.summary = name || ical_summary
        e.description = note || ical_description
        e.dtstart = Icalendar::Values::DateTime.new(starts_at, tzid: Config.tz)
        e.dtend = Icalendar::Values::DateTime.new(ends_at, tzid: Config.tz)
        e.location = room.to_s
        e.ip_class = 'PUBLIC'
        e.created = created_at
        e.last_modified = updated_at
        e.uid = "#{self.id}@#{Config.domain}"
        e.url = "/events/#{self.id}" # FIXME! Absolute URL
        #e.add_comment()
      end
    end

    # TODO: extract hardcoded strings to config file
    EVENT_TYPE_TRANSLATIONS = {
        tutorial: 'cvičení',
        lecture: 'přednáška',
        laboratory: 'laboratoř'
    }

    def localized_event_type
      EVENT_TYPE_TRANSLATIONS[event_type.to_sym] if event_type
    end
  end

end
