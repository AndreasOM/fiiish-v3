extends ResourceFormatLoader
class_name NewZoneResourceLoader


func _init() -> void:
	pass
	
func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["nzne"])

func _get_resource_type(path: String) -> String:
	# print("NewZoneResourceLoader: ", path )
	if path.ends_with(".nzne"):
		return "NewZone"
	else:
		return ""

func _handles_type(type: StringName) -> bool:
	return type == "Resource"
	
func _load(_path: String, original_path: String, _use_sub_threads: bool, _cache_mode: int) -> Variant:
	# print("!!!!! Load ", original_path)
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

	if !s.serialize_chunk_magic( [0x46, 0x49, 0x53, 0x48, 0x4e, 0x5a, 0x4e] ):
		push_error( "Broken chunk magic")
		return false

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
	# print( "Name: ", name )
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
	
	#print( "Difficulty: ", difficulty )
	#print( "size_x    %f: " % size_x )
	#print( "size_y    %f: " % size_y )
		#self.difficulty = f.read_u16();
		#self.size.x = f.read_f32();
		#self.size.y = f.read_f32();

	n.layers.serialize( s )
		
	return n
