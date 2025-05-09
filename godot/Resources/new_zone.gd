extends Resource
class_name NewZone

var name: String = "[unknown]"
var width: float = 0.0
var height: float = 0.0
var difficulty: int = 0

var layers: SerializableArray = SerializableArray.new(
	func() -> NewZoneLayer:
		return NewZoneLayer.new() 
)

func serialize( s: Serializer ) -> bool:
	var magic: int = 0x4f53;
	magic = s.serialize_u16( magic );
	
	if magic != 0x4f53:
		push_error("Broken zone magic %04x" % magic )
		return false

	var version: int = 1;
	version = s.serialize_u16( version );
	
	if version != 1:
		push_error("Unsupported zone version %04x" % version )
		return false

	if !s.serialize_chunk_magic( [0x46, 0x49, 0x53, 0x48, 0x4e, 0x5a, 0x4e] ):
		push_error( "Broken zone chunk magic")
		return false

	var flags = 0x45;
	flags = s.serialize_u8( flags )

	if flags != 0x45:	# 'E'
		push_error( "Compression/flags '%c' not supported for zone." % flags)
		return false
	
	var chunk_version: int = 2;
	chunk_version = s.serialize_u32( chunk_version );
#
	if chunk_version != 2:
		push_error("Unsupported zone chunk_version %04x" % chunk_version )
		return false

	self.name = s.serialize_fixed_string( 64, self.name )	
	self.difficulty = s.serialize_u16( self.difficulty )
	self.width = s.serialize_f32( self.width )
	self.height = s.serialize_f32( self.height )
	self.layers.serialize( s )
	
	return true

func get_layer( layer_name: String ): # -> NewZoneLayer:
	for l in self.layers.iter():
		if l.name == layer_name:
			return l
	
	return null
	
func ensure_layer( layer_name: String ) -> NewZoneLayer:
	var l = self.get_layer( layer_name )
	if l != null:
		return l
	
	l = NewZoneLayer.new()
	l.name = layer_name
	
	self.layers.push_back( l )
	
	return l

	
	
