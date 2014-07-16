require 'role_playing'

class Paginating
  include RolePlaying::Context

  def initialize(dataset)
    @dataset = dataset
  end

  def call(offset: 0, limit: 20)
    PaginatedDataset(@dataset).paginate(offset, limit)
  end

  role :PaginatedDataset do
    def paginate(offset, limit)
      self.limit(limit).offset(offset)
    end

    def total
      self.count
    end
  end

end
