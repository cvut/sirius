module Middleware
  class DBConnectionSweeper
    def initialize(app)
      @app = app
    end

    def call(env)
      response = @app.call(env)
    ensure
      ActiveRecord::Base.clear_active_connections!
      response
    end
  end
end
