dir = File.dirname(__FILE__)
lib_path = File.expand_path("#{dir}/../lib")
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

require 'titleize'

RSpec.configure do |rspec|
	rspec.deprecation_stream = 'log/deprecations.log'
end