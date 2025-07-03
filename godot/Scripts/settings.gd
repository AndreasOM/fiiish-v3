class_name Settings

const current_version: int = 3
const oldest_supported_version: int = 1


var _kids_mode_enabled: bool = false

## version 2
var _developer_dialog_version: int = 0

## version 3
var _is_music_enabled: bool = true
var _is_sound_enabled: bool = true

## not serialized
var _is_dirty: bool = false

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
	
func reset() -> void:
	self._kids_mode_enabled = false
	self._is_music_enabled = true
	self._is_sound_enabled = true
	self._is_dirty = true
		
func save() -> bool:
	var p = get_save_path()
	print("Saving settings to %s" % p)
	var s = Serializer.new()
	if !serialize( s ):
		push_warning("Failed serializing settings");
		return false
	
	s.save_file(p)
	
	return true

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

	# version 2
	if version < 2:
		return true
		
	self._developer_dialog_version = s.serialize_u16( self._developer_dialog_version )
		
	# version 3
	if version < 3:
		return true
		
	self._is_music_enabled = s.serialize_bool( self._is_music_enabled )
	self._is_sound_enabled = s.serialize_bool( self._is_sound_enabled )
	
	return true
		
	
func is_kids_mode_enabled() -> bool:
	return self._kids_mode_enabled

func enable_kids_mode() -> void:
	if self._kids_mode_enabled:
		return
	self._kids_mode_enabled = true
	_is_dirty = true

func disable_kids_mode() -> void:
	if !self._kids_mode_enabled:
		return
	self._kids_mode_enabled = false
	_is_dirty = true


## version 2

func get_developer_dialog_version() -> int:
	return self._developer_dialog_version

func set_developer_dialog_version( version: int ) -> void:
	if self._developer_dialog_version == version:
		return
	self._developer_dialog_version = version
	self._is_dirty = true

## version 3

func is_music_enabled() -> bool:
	return self._is_music_enabled
	
func is_sound_enabled() -> bool:
	return self._is_sound_enabled

func enable_music() -> void:
	if self._is_music_enabled:
		return
	self._is_music_enabled = true
	self._is_dirty = true

func disable_music() -> void:
	if !self._is_music_enabled:
		return
	self._is_music_enabled = false
	self._is_dirty = true
	
func enable_sound() -> void:
	if self._is_sound_enabled:
		return
	self._is_sound_enabled = true
	self._is_dirty = true

func disable_sound() -> void:
	if !self._is_sound_enabled:
		return
	self._is_sound_enabled = false
	self._is_dirty = true
