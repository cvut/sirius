require 'interpipe/interactor'
require 'active_support/inflector'

class Sync
  include Interpipe::Interactor

  class << self

    attr_accessor :model_class, :key_name, :matching_attributes, :skip_updating

    def [](model_class, key_name: nil, matching_attributes: [:id], skip_updating: [])
      cls = Class.new(self)
      cls.model_class = model_class
      cls.key_name = generate_key_name(model_class, key_name)
      cls.matching_attributes = matching_attributes
      cls.skip_updating = skip_updating
      cls
    end

    def generate_key_name(model_class, key_name)
      return key_name if key_name
      model_class.to_s.tableize.to_sym
    end
  end

  def perform(args)
    @models = args[key_name]
    raise "Missing key #{key_name} in Sync#perform arguments." unless @models
    @rest = args.select { |k,v| k != key_name }
    @models.each do |model|
      model_hash = model.to_hash
      update_columns = model_hash.keys.reject do |k|
        matching_attributes.include?(k) || skip_updating.include?(k)
      end
      upsert_options = { target: matching_attributes }
      unless update_columns.empty?
        upsert_update = update_columns.map { |key| [ key.to_sym, "excluded__#{key}".to_sym ] }.to_h
        if model_class.columns.include?(:updated_at)
          upsert_update_where = update_columns.map { |key|
            ["#{model_class.table_name}__#{key}".to_sym, "excluded__#{key}".to_sym]
          }.to_h
          update_if = Sequel.~(upsert_update_where) # only perform the update if at least one column differs
          updated_at_case = Sequel.case(
            [[update_if, Sequel.function(:NOW)]],
            "#{model_class.table_name}__updated_at".to_sym # default value
          )
          upsert_options[:update] = upsert_update.merge(updated_at: updated_at_case)
        else
          upsert_options[:update] = upsert_update
        end
      end
      if model_class.columns.include?(:created_at)
        model_hash.merge!({ created_at: Sequel.function(:NOW) }) { |key, oldval, newval| oldval }
      end
      if model_class.columns.include?(:updated_at)
        model_hash.merge!({ updated_at: Sequel.function(:NOW) }) { |key, oldval, newval| oldval }
      end
      model.id = model_class.dataset.insert_conflict(upsert_options).insert(model_hash)
      model.instance_variable_set(:@new, false)
    end
  end

  def results
    {key_name => @models}.merge(@rest)
  end

  private

  def key_name
    self.class.key_name
  end

  def model_class
    self.class.model_class
  end

  def matching_attributes
    self.class.matching_attributes
  end

  def skip_updating
    self.class.skip_updating
  end

end
