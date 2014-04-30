module Middleware
  class Logger
    def initialize(app, logger)
      @app = app
      @logger = logger
    end

    def call(env)

      headers = env.select {|k,v| k.start_with? 'HTTP_'}
      .map {|pair| [pair[0].sub(/^HTTP_/, ''), pair[1]].join(": ")}
      .sort

      request_params = env['rack.input'].read

      @logger.info "Request: #{env["REQUEST_METHOD"]} #{env["PATH_INFO"]} #{headers} #{request_params}"

      @app.call(env).tap do |response|
        status, headers, body = *response

        @logger.info "Response: #{status}"
        @logger.info "Headers: #{headers}"
        @logger.info "Response:"

        body.each do |line|
          @logger.info line
        end
      end
    end
  end
end
