require 'interpipe/interactor'
require 'active_support/inflector'

class Sync
  include Interpipe::Interactor

  class << self

    attr_accessor :model_class, :key_name, :matching_attribute

    def [](model_class, key_name: nil, matching_attribute: :id)
      cls = Class.new(self)
      cls.model_class = model_class
      cls.key_name = generate_key_name(model_class, key_name)
      cls.matching_attribute = matching_attribute
      cls
    end

    def generate_key_name(model_class, key_name)
      return key_name if key_name
      model_class.to_s.tableize.to_sym
    end
  end

  def perform(args)
    models = args[key_name]
    raise "Missing key #{key_name} in Sync#perform arguments." unless models
    models.each do |model|
      existing_model = find_existing_model(model)
      if existing_model
        existing_model.update_all(model.values)
      else
        model.save
      end
    end
  end

  private

  def find_existing_model(model)
    lookup_value = model.send(matching_attribute)
    model_class.find(matching_attribute => lookup_value) if lookup_value
  end

  def key_name
    self.class.key_name
  end

  def model_class
    self.class.model_class
  end

  def matching_attribute
    self.class.matching_attribute
  end

end
