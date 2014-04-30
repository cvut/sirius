require File.join(File.dirname(__FILE__), 'init')

use Rack::CommonLogger, $logger
use Middleware::Logger, $logger
use Middleware::DBConnectionSweeper

run API::Base
