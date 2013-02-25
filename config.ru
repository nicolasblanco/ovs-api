# This file is used by Rack-based servers to start the application.

require "rack/cors"
require File.expand_path("../api", __FILE__)

use Rack::Static, :urls => ["/assets"]
use Rack::Cors do
  allow do
    origins '*'
    resource '*', :headers => :any, :methods => [:get, :post, :options]
  end
end

run OVSApi::API
