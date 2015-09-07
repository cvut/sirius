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

    def initialize(*given_scopes)
      prefixed_scopes = given_scopes.flatten.map { |it| prepend_prefix_if_missing(it, 'urn:ctu:oauth:sirius') }
      @scopes = Set.new(prefixed_scopes)
    end

    def to_s
      scopes.to_s
    end

    def include_any?(items)
      items_set = Array(items).to_set
      !(scopes & items_set).empty?
    end

    private

    def prepend_prefix_if_missing(str, prefix)
      if str.start_with?('urn:')
        str
      else
        "#{prefix}:#{str}"
      end
    end

  end
end
