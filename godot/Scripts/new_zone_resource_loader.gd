extends ResourceFormatLoader
class_name NewZoneResourceLoader


func _init() -> void:
	pass
	
func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["nzne"])

func _get_resource_type(path: String) -> String:
	print("NewZoneResourceLoader: ", path )
	return "NewZone"

func _handles_type(type: StringName) -> bool:
	return type == "Resource"
	
func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	print("!!!!! Load ", original_path)
	var n = NewZone.new()
	
	var s = Serializer.new()
	s.load_file( original_path )

	var magic: int = 0;
	magic = s.serialize_u16( magic );
	
	if magic != 0x4f53:
		push_error("Broken magic %04x" % magic )
		return n

	
	var version: int = 0;
	version = s.serialize_u16( version );
	
	if version != 1:
		push_error("Unsupported version %04x" % version )
		return n
		
	var chunk_magic = [0x46, 0x49, 0x53, 0x48, 0x4e, 0x5a, 0x4e]
	
	for m in chunk_magic:
		var b: int = 0;
		b = s.serialize_u8( b )
		if b != m:
			push_error( "Broken chunk magic")
			return n

	var flags = 0;
	flags = s.serialize_u8( flags )

	if flags != 0x45:	# 'E'
		push_error( "Compression/flags '%c' not supported." % flags)
		return n
	
	var chunk_version: int = 0;
	chunk_version = s.serialize_u32( chunk_version );
#
	if chunk_version != 2:
		push_error("Unsupported chunk_version %04x" % chunk_version )
		return n

	var name: String = ""
	name = s.serialize_fixed_string( 64, name )	
	print( "Name: ", name )
	n.name = name
	
	var difficulty: int = 0
	difficulty = s.serialize_u16( difficulty )
	
	n.difficulty = difficulty
	
	var size_x = 0.0
	size_x = s.serialize_f32( size_x )
	var size_y = 0.0
	size_y = s.serialize_f32( size_y )
	
	n.width = size_x
	n.height = size_y
	
	print( "Difficulty: ", difficulty )
	print( "size_x    %f: " % size_x )
	print( "size_y    %f: " % size_y )
		#self.difficulty = f.read_u16();
		#self.size.x = f.read_f32();
		#self.size.y = f.read_f32();

	var layer_count = 0
	layer_count = s.serialize_u16( layer_count )

	for l in range(layer_count):
		var layer = NewZoneLayer.new()
		# :TODO: layer.serialize( s )	
		var layer_name: String = ""
		layer.name = s.serialize_fixed_string( 16, layer.name )	
		print( "Layer Name: ", layer.name )
		var object_count = 0
		object_count = s.serialize_u16( layer_count )
		for o in range(object_count):
			var object = NewZoneLayerObject.new()
			var o_id = 0;
			
			object.id = s.serialize_u16( object.id )
			object.crc = s.serialize_u32( object.crc )
			object.pos_x = s.serialize_f32( object.pos_x )
			object.pos_y = s.serialize_f32( object.pos_y )
			object.pos_y = -object.pos_y # :HACK:
			object.rotation = s.serialize_f32( object.rotation )
			
			layer.objects.push_back( object )
		
		n.layers.push_back( layer )
		
	return n
