require 'interpipe/interactor'
require 'active_support/inflector'

class Sync
  include Interpipe::Interactor

  class << self

    attr_accessor :model_class, :key_name

    def [](model_class, key_name = nil)
      cls = Class.new(self)
      cls.model_class = model_class
      cls.key_name = generate_key_name(model_class, key_name)
      cls
    end

    def generate_key_name(model_class, key_name)
      return key_name if key_name
      model_class.to_s.tableize.to_sym
    end
  end


  def perform(models)

  end
end
