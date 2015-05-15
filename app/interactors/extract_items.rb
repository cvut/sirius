require 'interpipe/interactor'

class ExtractItems
  include Interpipe::Interactor

  def perform(**options)
    @options = options
    collection = options[collection_key]
    raise "#{self.class.name}: Missing collection key '#{collection_key}'." unless collection
    @items = collection.map { |item| item.send(attribute) }.reject(&:nil?).uniq { |i| i.link_id }
  end

  def results
    { result_key => @items }.merge(@options)
  end

  class << self
    attr_accessor :collection, :attribute, :result_key

    def [](result_key, from:, attr:)
      Class.new(self).tap do |cls|
        cls.collection = from
        cls.attribute = attr
        cls.result_key = result_key
      end
    end
  end

  private
  def collection_key
    self.class.collection
  end

  def attribute
    self.class.attribute
  end

  def result_key
    self.class.result_key
  end
end
