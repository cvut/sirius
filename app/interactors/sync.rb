require 'interpipe/interactor'
require 'active_support/inflector'

# An interactor class for inserting or updating model instances to the database.
#
# In order to use the this interactor, you first need to create a configured descendant of {Sync}
# by calling {.[]} operator.
#
# @example configure and use the Sync interactor
#   sync = Sync[
#     Event,
#     matching_attributes: [:faculty, :source_type, :source_id, :absolute_sequence_number],
#     skip_updating: [:relative_sequence_number]
#   ]
#   sync.perform(events: [event1, event2])
#
class Sync
  include Interpipe::Interactor

  class << self

    attr_accessor :model_class, :key_name, :matching_attributes, :skip_updating

    # Creates a new {Sync} descendant class with parameters set for syncing a specific model.
    # In order to properly use Sync functionality, you need to use this operator.
    #
    # @param model_class [Class] Class of the model that should be synced (should inherit from {Sequel::Model}).
    # @param key_name [Symbol] Optional name of the key under which the collection of models
    #   for syncing is stored in {#perform} args hash. Defaults to inferred table name
    #   from model_class name.
    # @param matching_attributes [Array<Symbol>] List of columns that are used for matching model
    #   instances with existing database records. These columns can't be updated.
    # @param skip_updating [Array<Symbol>] List of columns that should not be updated in
    #   case the model already exists in the database. If the model is newly inserted,
    #   this configuration is ignored.
    # @return [Class] a new class which inherits from Sync and is configured for
    #   syncing instances of a specific model
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

  # Synchronizes a collection of models.
  #
  # @param args [Hash] with collection of models under key configured by {key_name} parameter
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

  # Creates or updates a single model in the database and sets its id.
  #
  # @param model [Sequel::Model] instance to sync
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

    inserted_id = model_class.dataset.insert_conflict(upsert_options).insert(model_insert_clause)
    # If model was not inserted, the above returns nil
    if inserted_id
      model.id = inserted_id
    end
    model.instance_variable_set(:@new, false)
  end

  # Generates created_at and updated_at fields for insert clause if model has
  # either created_at or updated_at column.
  #
  # @return [Hash] with timestamps
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

  # Generates updated_at value for update definition if model has `updated_at` column.
  #
  # The generated value is a SQL case condition which returns either
  # `NOW()` function if at least one of the record fields differ
  # from current state or old value of updated_at otherwise.
  #
  # @return [Hash] with timestamps
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
