# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../api', __FILE__)
use Rack::Static, :urls => ["/assets"]

run OVSApi::API
