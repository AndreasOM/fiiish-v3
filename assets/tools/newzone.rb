$:.unshift File.dirname(__FILE__)

require 'rubygems'
require 'bundler/setup'

require 'zlib'

# require 'svg'

require 'rexml/document'
require 'rexml/xpath'
include REXML

require 'vector2'

def name2crc( name )
	name_clean = name.chomp.strip.upcase.gsub( /\W/, '_' )
	crc = Zlib.crc32( name_clean.downcase )
	crc
end

class NewZone

	class Tile
		attr_reader :gid, :object_id, :object_crc, :width, :height

		def initialize( gid, object_id, width, height )
			@gid = gid
			@object_id = object_id
			@object_crc = name2crc( object_id )
			@width = width
			@height = height
		end
	end

	class Layer
		attr_reader :name, :objects

		def initialize( name )
			@name = name
			@objects = {}
		end
		def addObject( object )
			@objects[ object.id ] = object
		end
	end

	class Object

		attr_reader :id, :tile_id, :object_id, :x, :y, :rot, :object_crc

		def initialize( id, tile_id, object_id, x, y, rot )
			@id = id
			@tile_id = tile_id
			@object_id = object_id
			@object_crc = name2crc( object_id )
			@x = x
			@y = y
			@rot = rot 
		end
	end
	
	def initialize
		@name = ""
		@difficulty = 0
		@width = 0.0
		@height = 1024.0

		@tiles = {}
		@objects = {}
		@layers = {}

		@itemIds = {}
		@itemIds[ "RockA" ] = 2
		@itemIds[ "RockB" ] = 3
		@itemIds[ "RockC" ] = 4
		@itemIds[ "RockD" ] = 5
		@itemIds[ "RockE" ] = 6
		@itemIds[ "RockF" ] = 7
		@itemIds[ "SeaweedA" ] = 8
		@itemIds[ "SeaweedB" ] = 9
		@itemIds[ "SeaweedC" ] = 10
		@itemIds[ "SeaweedD" ] = 11
		@itemIds[ "SeaweedE" ] = 12
		@itemIds[ "SeaweedF" ] = 13
		@itemIds[ "SeaweedG" ] = 14
		@itemIds[ "Block1x1" ] = 15

		@itemSizes = []
		@itemSizes << [ 4, 4 ]
		@itemSizes << [ 4, 4 ]

		@itemSizes << [ 217, 130 ]	# RockA
		@itemSizes << [ 272, 313 ]	# RockB
		@itemSizes << [ 226, 516 ]	# RockC
		@itemSizes << [ 275, 606 ]	# RockD
		@itemSizes << [ 242, 793 ]	# RockE
		@itemSizes << [ 571, 752 ]	# RockF
		@itemSizes << [ 180, 480 ]	# :FIXME: SeaweedA 
		@itemSizes << [ 165, 440 ]	# :FIXME: SeaweedB
		@itemSizes << [ 165, 440 ]	# :FIXME: SeaweedC
		@itemSizes << [ 165, 440 ]	# :FIXME: SeaweedD
		@itemSizes << [ 165, 440 ]	# :FIXME: SeaweedE
		@itemSizes << [ 165, 440 ]	# :FIXME: SeaweedF
		@itemSizes << [ 165, 440 ]	# :FIXME: SeaweedG
		@itemSizes << [ 128, 128 ]	# Block1x1

		@pickupIds = {}
		@pickupIds[ "Coin" ] = 1

		@pickupSizes = []
		@pickupSizes[ 1 ] = [ 64, 64 ]

		@offsetX = 0.0
	end

	def addTile( gid, object_id, width, height )
		tile = Tile.new( gid, object_id, width, height )
		@tiles[ gid ] = tile
	end

	def addLayer( name )
		layer = Layer.new( name )
		@layers[ name ] = layer
		layer
	end

	def createObject( id, gid, x, y, rot )
		object_id = @tiles[ gid ].object_id
		object = Object.new( id, gid, object_id, x, y, rot )
#		@objects[ id ] = object
		object
	end

	def fromTmxFile( infile )
		@name = File.basename( infile.path, ".tmx" )
		p @name

		doc = Document.new( infile )
		root = doc.root

		doc.elements.each( 'map' ) do |map|
			tilewidth = ( map.attributes[ 'tilewidth' ] || 32 ).to_i
			tileheight = ( map.attributes[ 'tileheight' ] || 32 ).to_i
			w = ( map.attributes[ 'width' ] || 32 ).to_i
			h = ( map.attributes[ 'height' ] || 32 ).to_i
			@width = w * tilewidth
			@height = h * tileheight

			map.elements.each( 'properties' ) do |properties|
				properties.elements.each( 'property' ) do |property|
					pname = property.attributes[ 'name' ]
					pval = property.attributes[ 'value' ]
					case pname
						when 'Difficulty'
							@difficulty = pval.to_i
					end
				end
			end
			map.elements.each( 'tileset' ) do |tileset|
				firstgid = tileset.attributes[ 'firstgid' ].to_i
				p tileset.attributes[ "name" ]
					puts "Tiles:"
				tileset.elements.each( 'tile' ) do |tile|
					id = tile.attributes[ 'id' ].to_i
					gid = firstgid + id
					object_id = ''
					tile.elements.each( 'properties' ) do |properties|
						properties.elements.each( 'property' ) do |property|
							pname = property.attributes[ 'name' ]
							pval = property.attributes[ 'value' ]
#							p pname
#							p pval
							case pname
								when 'OBJECT_ID'
									object_id = pval
								else
									puts "Ignoring property >#{pname}<"
							end
						end
					end
					w = 0
					h = 0
					tile.elements.each( 'image' ) do |image|
						w = image.attributes[ 'width' ].to_i
						h = image.attributes[ 'height' ].to_i
##						source = image.attributes[ 'source' ]
					end
					puts "\t#{gid} #{object_id} #{w} #{h}"
					addTile( gid, object_id, w, h )
#					XPath.first( tile, 'properties' ) do |object_id|
#						puts "---"
#						p object_id
#					end
				end
			end
			map.elements.each( 'objectgroup' ) do |objectgroup|
				# :TODO: handle groups
				layername = objectgroup.attributes[ 'name' ]
				layer = addLayer( layername )
				objectgroup.elements.each( 'object' ) do |object|
					id = object.attributes[ 'id' ].to_i
					gid = object.attributes[ 'gid' ].to_i
					x = object.attributes[ 'x' ].to_f
					y = object.attributes[ 'y' ].to_f
					rot = ( object.attributes[ 'rotation' ] || 0 ).to_f
					object = createObject( id, gid, x, y, rot )
					layer.addObject( object )
				end
			end
		end


		puts @tiles
		puts "#{@width}x#{@height} #{@difficulty}"
		@layers.each do |name, layer|
			puts "\t#{layer.name} ->" ## #{layer.objects}"
			layer.objects.each do |id, o|
				puts "\t\t% 16s\t%5.2f, %5.2f r #{o.rot}" % [ o.object_id, o.x, o.y ]
			end
		end
#		puts @layers
	end

	def fromNewZoneFile( infile )
	end

	def toNZNE( outfile, compress = false )
		name = File.basename( outfile.path, ".nzne" )
		data = ""
		data += [ 0x4f53, 0x0001 ].pack( 'SS' )
		data += [ 'F', 'I', 'S', 'H', 'N', 'Z', 'N', compress ? 'Z' : 'E', 2, 0, 0, 0 ].pack( 'AAAAAAAACCCC' )
		tmp = ""
		tmp += [ @name ].pack( 'a64' )
		tmp += [ @difficulty ].pack( 'S' )
		tmp += [ @width, @height ].pack( 'ff' )
		tmp += [ @layers.size ].pack( 'S' )
		@layers.each{ |n, layer|
			tmp += [ layer.name ].pack( 'a16' )
			tmp += [ layer.objects.size ].pack( 'S' )

			layer.objects.each{ |n, object|
				t = @tiles[ object.tile_id ]

				pos2 = Vector2.new( 0.0, 0.0 )
				off = Vector2.new( 0.5*t.width, 0.5*t.height )
				pos2.add( off )
				pos2.rotateDeg( object.rot )
				pos2.sub( off )
				pos2.y += 0.5*t.height
				pos2.x += 0.5*t.width
				y = ( 1024 - ( object.y+512 ) )
				pos2.add( Vector2.new( object.x, y ) )

				tmp += [ object.id, object.object_crc, pos2.x, pos2.y, object.rot ].pack( 'SLfff' )
			}
		}

		c = Zlib::Deflate.deflate( tmp, 9 )
		if compress
			puts "Saving   compressed (#{tmp.size} -> #{c.size}): #{name} "
			data += c
		else
			puts "Saving uncompressed (#{tmp.size} -> #{c.size}): #{name} "
			data += tmp
		end

		outfile.write( data )
	end
end

