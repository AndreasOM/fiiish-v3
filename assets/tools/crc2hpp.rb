#!/usr/bin/env ruby

require 'zlib'

if( ARGV.size != 2 )
then
  puts "Usage: crc2hpp <in> <out>"
  exit
end

IN = ARGV[ 0 ]
OUT = ARGV[ 1 ]

File.open( IN, "r" ) do |infile|
  File.open( OUT, "w" ) do |outfile|
    infile.each do |name|
      name = name.chomp
      if m = name.match( /^\s*\w+\s*$/ ) then
        name = m[ 0 ].upcase.gsub( /\W/, '_' )
        crc = Zlib::crc32( name.downcase )
        outfile.printf "#define\tCRC_%s\t0x%08x\n", name.upcase, crc
      else
        outfile.printf "// ignored: >>%s<<\n", name
      end
    end
  end
end

