class_name ZoneEditorSave

const current_version: int = 1
const oldest_supported_version: int = 1

# version 1
var _last_zone_filename: String = ""
var _offset: Vector2 = Vector2.ZERO
var _fish_position: Vector2 = Vector2.ZERO

func serialize( s: Serializer ) -> bool:

	if !s.serialize_chunk_magic( [0x4f, 0x4d, 0x46, 0x49, 0x49, 0x49, 0x53, 0x48, 0x5a, 0x45, 0x53] ):
		push_error( "Broken chunk magic")
		return false

	var version: int = current_version;
	version = s.serialize_u16( version )
	if version < oldest_supported_version:
		push_warning("Version not supported ", version)
		return false

	self._last_zone_filename = s.serialize_fixed_string( 64, self._last_zone_filename )
	self._offset.x = s.serialize_f32( self._offset.x )
	self._offset.y = s.serialize_f32( self._offset.y )
	self._fish_position.x = s.serialize_f32( self._fish_position.x )
	self._fish_position.y = s.serialize_f32( self._fish_position.y )

	return true

func set_offset( o: Vector2 ) -> void:
	self._offset = o
	
func get_offset( ) -> Vector2:
	return self._offset

func set_last_zone_filename( fn: String ) -> void:
	self._last_zone_filename = fn
	
func get_last_zone_filename( ) -> String:
	return self._last_zone_filename
