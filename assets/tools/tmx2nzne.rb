$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'bundler/setup'

require 'newzone'

input = ARGV.shift
output = ARGV.shift
svgout = ARGV.shift

inFile = File.new( input )

newzone = NewZone.new
newzone.fromTmxFile( inFile )

File.open( output, 'wb' ) do |outFile|
	newzone.toNZNE( outFile )
end


#if svgout
#	zone.toSVG( svgout )
#end
