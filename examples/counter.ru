#use Rack::CommonLogger
require 'counter'
run Wof::Handler.new(Main)
