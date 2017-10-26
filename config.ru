require './dhl_connector'
run Sinatra::Application
$stderr.sync = true
$stdout.sync = true
