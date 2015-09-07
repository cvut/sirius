require 'forwardable'

module SiriusApi
  class Scopes

    include Enumerable
    extend Forwardable
    def_delegators :@scopes, :each

    READ_ALL = 'urn:ctu:oauth:sirius:read'.freeze
    READ_PERSONAL = 'urn:ctu:oauth:sirius:personal:read'.freeze
    READ_LIMITED = ['urn:ctu:oauth:sirius:limited-by-idm:read', 'urn:ctu:oauth:sirius.read'].freeze

    attr_reader :scopes

    def initialize(*scopes)
      @scopes = Set.new(scopes.flatten)
    end

    def to_s
      scopes.to_s
    end

    def include_any?(items)
      items_set = Array(items).to_set
      !(scopes & items_set).empty?
    end

  end
end
