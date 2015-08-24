require 'forwardable'

module SiriusApi
  class Scopes

    include Enumerable
    extend Forwardable
    def_delegators :@scopes, :each

    SCOPE_PREFIX = Config.oauth_scope_base

    READ_ALL = "#{SCOPE_PREFIX}:read".freeze
    READ_PERSONAL = "#{SCOPE_PREFIX}:personal:read".freeze
    READ_LIMITED = ["#{SCOPE_PREFIX}:limited-by-idm:read", "#{SCOPE_PREFIX}.read"].freeze

    attr_reader :scopes

    def initialize(*given_scopes)
      prefixed_scopes = given_scopes.flatten.map { |it| prepend_prefix_if_missing(it, SCOPE_PREFIX) }
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
