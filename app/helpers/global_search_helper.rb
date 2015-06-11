require 'sequel'
require 'sequel/extensions/core_refinements'

module GlobalSearchHelper
  using Sequel::CoreRefinements

  module_function

  def search(query)
    name = Sequel.hstore_op(:name)

    # TODO: search also in courses.name and people.full_name
    DB.from([
        DB.select(:id, name['cs'].as(:title), 'course'.as(:type)).from(:courses),
        DB.select(:id, :full_name.as(:title), 'person'.as(:type)).from(:people),
        DB.select(:id, nil, 'room'.as(:type)).from(:rooms)
      ].reduce(:union))
      .where('id % ?', query)
      .order('id <-> ?'.lit(query))
  end
end
