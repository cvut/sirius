require 'chewy'
require 'roles/page_meta'
require 'models/course'
require 'models/person'
require 'models/room'

##
# Definition of ElasticSearch index for the /search resource.
#
class MultiSearchIndex < Chewy::Index

  SearchResult = Struct.new(:id, :title, :type)

  DEFAULT_OPTS = {
    index_analyzer: 'standard_ascii_engram',
    search_analyzer: 'standard_ascii',
    include_in_all: false
  }

  settings analysis: {
    analyzer:  [ :course_code, :course_code_engram, :czech_ascii, :standard_ascii,
                 :standard_ascii_engram ],
    filter:    [ :czech_stemmer, :czech_stop, :edge_ngram ],
    tokenizer: [ :course_code ]
  }


  define_type Course do
    root include_in_all: false

    field :id, index_analyzer: 'course_code_engram', search_analyzer: 'course_code',
               index_options: 'docs'
    field :title, analyzer: 'czech_ascii', index_options: 'docs', value: ->{ name['cs'] }
  end

  define_type Person do
    root DEFAULT_OPTS

    field :id, index_options: 'docs'
    field :title, index_options: 'docs', value: ->{ full_name }
    field :last_name, index_options: 'docs', value: ->(p) { extract_last_name(p.full_name) }
  end

  define_type Room do
    root DEFAULT_OPTS

    field :id, index_options: 'docs'
  end


  ##
  # Search courses, people and rooms with the given string in ID or title.
  #
  # @param str [String] a string to search.
  # @param offset [Integer]
  # @param limit [Integer]
  # @return [Array<SearchResult>] an wrapped with {PageMeta}.
  #
  def self.search(str, offset: 0, limit: 10)
    transform_result query(multi_match: {
      query: str,
      type: 'best_fields',
      fields: %w[course.id^2 course.title person.id person.last_name person.title room.id],
      operator: 'and'
    }).only(:id, :title).limit(limit).offset(offset)
  end

  private

  def self.extract_last_name(full_name)
    # Very simple heuristic to detect a degree.
    is_degree = ->(s) { s.include?('.') || s[1] =~ /[[:upper:]]/ }
    full_name.split.reject(&is_degree).last.chomp(',')
  end

  def self.transform_result(query)
    data = query.map do |entry|
      SearchResult.new(entry.id, entry.title, entry._data['_type'])
    end
    opts = query.criteria.request_options

    PageMeta.new(data, limit: opts[:size], offset: opts[:from], count: query.total)
  end
end
