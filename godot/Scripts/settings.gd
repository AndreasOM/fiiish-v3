class_name Settings

const current_version: int = 1
const oldest_supported_version: int = 1


var _kids_mode_enabled: bool = false

## not serialized
var _isDirty: bool = false

static func get_save_path() -> String:
	return "user://settings.data"
	
	
static func load() -> Settings:
	var p = get_save_path()
	print("Loading settings from %s" % p)
	var s = Serializer.new()
	if !s.load_file( p ):
		print("Couldn't load settings data")
		return Settings.new()
		
	var settings = Settings.new()
	if !settings.serialize( s ):
		push_warning("Failed serializing settings");
		return null
		
	return settings
	
func reset():
	self._kids_mode_enabled = false
	self._isDirty = true
		
func save():
	var p = get_save_path()
	print("Saving settings to %s" % p)
	var s = Serializer.new()
	if !serialize( s ):
		push_warning("Failed serializing settings");
	
	s.save_file(p)

func serialize( s: Serializer ) -> bool:

	if !s.serialize_chunk_magic( [0x4f, 0x4d, 0x46, 0x49, 0x49, 0x49, 0x53, 0x48, 0x53, 0x45, 0x54, 0x54] ):
		push_error( "Broken chunk magic")
		return false
		
	var version: int = current_version;
	version = s.serialize_u16( version )
	if version < oldest_supported_version:
		push_warning("Version not supported ", version)
		return false

	self._kids_mode_enabled = s.serialize_bool( self._kids_mode_enabled )
		
	return true
		
	
func is_kids_mode_enabled() -> bool:
	return self._kids_mode_enabled

func enable_kids_mode():
	if self._kids_mode_enabled:
		return
	self._kids_mode_enabled = true
	_isDirty = true

func disable_kids_mode():
	if !self._kids_mode_enabled:
		return
	self._kids_mode_enabled = false
	_isDirty = true
