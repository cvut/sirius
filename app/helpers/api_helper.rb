##
# Helper methods used in Grape's API endpoints.
module ApiHelper

  ##
  # Present a given objects(s) with a representer.
  #
  # Dervied from {Grape::Endpoint#present}, wraps an object
  # with a representer, but always works with an objects collection
  # (singular objects are wrapped into an Array).
  #
  # Representer can be given explicitly, or derived implicitly
  # from Grape's representations defined with {Grape::API#respresent}
  # macro.
  #
  # @param data [Enumerable,Object] a collection or an object to represent
  # @param with [BaseRepresenter] optional explicit representer
  # @return [BaseRepresenter<Array>] given object wrapped into a representer (and Array)
  # @see http://intridea.github.io/grape/docs/Grape/Endpoint.html#present-instance_method
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
