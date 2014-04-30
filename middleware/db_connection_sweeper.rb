module Middleware
  class DBConnectionSweeper
    def initialize(app)
      @app = app
    end

    def call(env)
      response = @app.call(env)
    ensure
      DB.disconnect
      response
    end
  end
end
