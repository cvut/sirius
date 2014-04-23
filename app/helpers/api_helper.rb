module ApiHelper
  ## Helper for Roar representers
  ## Taken from  Napa::GrapeHelpers
  def represent(data, with: nil, **args)
    raise ArgumentError.new(":with option is required") if with.nil?

    if data.respond_to?(:to_a)
      return { data: data.map{ |item| with.new(item).to_hash(args) } }
    else
      return { data: with.new(data).to_hash(args)}
    end
  end
end
