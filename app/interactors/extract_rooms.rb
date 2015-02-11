require 'interpipe/interactor'

class ExtractRooms
  include Interpipe::Interactor

  def perform(**options)
    @options = options
    collection = options[collection_key]
    raise "#{self.class.name}: Missing collection key '#{collection_key}'." unless collection
    @rooms = collection.map { |item| item.send(attribute) }.reject(&:nil?).uniq { |i| i.link_id }
  end

  def results
    {kosapi_rooms: @rooms}.merge(@options)
  end

  class << self
    attr_accessor :collection, :attribute

    def [](collection:, attribute: :room)
      Class.new(self).tap do |cls|
        cls.collection = collection
        cls.attribute = attribute
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
end
