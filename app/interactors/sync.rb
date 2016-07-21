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
      upsert_model(model)
    end
  end

  def results
    {key_name => @models}.merge(@rest)
  end

  private

  %i[model_class key_name matching_attributes skip_updating].each do |key|
    define_method(key) { self.class.send(key) }
  end

  def upsert_model(model)
    model_hash = model.to_hash
    columns_to_update = model_hash.keys.reject do |k|
      matching_attributes.include?(k) || skip_updating.include?(k)
    end
    upsert_options = { target: matching_attributes }
    unless columns_to_update.empty?
      update_clause = columns_to_update.map { |key| [ key.to_sym, "excluded__#{key}".to_sym ] }.to_h
      timestamps = update_timestamps(columns_to_update)
      upsert_options[:update] = update_clause.merge(timestamps) { |key, oldval, newval| oldval }
    end
    model_insert_clause = model_hash.merge(insert_timestamps) { |key, oldval, newval| oldval }

    model.id = model_class.dataset.insert_conflict(upsert_options).insert(model_insert_clause)
    model.instance_variable_set(:@new, false)
  end

  def insert_timestamps
    timestamps = {}
    if model_class.columns.include?(:created_at)
      timestamps[:created_at] = Sequel.function(:NOW)
    end
    if model_class.columns.include?(:updated_at)
      timestamps[:updated_at] = Sequel.function(:NOW)
    end
    timestamps
  end

  def update_timestamps(columns_to_update)
    if model_class.columns.include?(:updated_at)
      columns_comparison = columns_to_update.map { |key|
        ["#{model_class.table_name}__#{key}".to_sym, "excluded__#{key}".to_sym]
      }.to_h
      update_condition = Sequel.~(columns_comparison) # only perform the update if at least one column differs
      updated_at_case = Sequel.case(
        [[update_condition, Sequel.function(:NOW)]],
        "#{model_class.table_name}__updated_at".to_sym # default value
      )
      { updated_at: updated_at_case }
    else
      { }
    end
  end

end
