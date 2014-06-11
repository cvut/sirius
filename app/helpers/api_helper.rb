module ApiHelper
  ## Simplified `present` method
  # - Seeks a relevant representer if not defined with `represent` macro
  # - Always works with collections
  def represent(data, with: nil, **args)

    # convert singular resource to a collection
    objects = Array(data)

    entity_class = with
    if entity_class.nil?
      object_class = objects.first.class
      # Iterate over ancestors to find a relevant representer
      # defined with `represent` macro
      object_class.ancestors.each do |potential|
        entity_class ||= (settings[:representations] || {})[potential]
      end
    end

    entity_class.new(objects)
  end
end
