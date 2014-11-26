module Sirius
  class KOSapiClientRegistry

    def initialize
      @registry = {}
      @default_client = nil
    end

    def client_for_faculty(faculty)
      @registry[faculty] || @default_client
    end

    def register_client(client, faculty, default: false)
      @registry[faculty] = client
      @default_client = client if default
    end

    def self.instance
      @instance ||= new
    end

  end
end
