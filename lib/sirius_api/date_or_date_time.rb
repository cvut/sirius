
module SiriusApi
  class DateOrDateTime
    def self.parse(value)
      # expect date string with fixed length, e.g.:
      # 2015-09-01
      if value.length == 10
        Date.parse(value)
      else
        DateTime.parse(value)
      end
    end
  end
end
