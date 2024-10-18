class_name Player

var _coins: int = 0
var _lastDistance: int = 0
var _totalDistance: int = 0
var _bestDistance: int = 0
var _playCount: int = 0
var _isMusicEnabled: bool = true
var _isSoundEnabled: bool = true
var _isDirty: bool = false

static func get_save_path() -> String:
	return "user://player.data"
	
static func load() -> Player:
	var p = get_save_path()
	print("Loading player from %s" % p)
	var s = Serializer.new()
	if !s.load_file( p ):
		print("Couldn't load player data")
		return null
		
	var player = Player.new()
	if !player.serialize( s ):
		push_warning("Failed serializing player");
		return null
		
	return player
	
func save():
	var p = get_save_path()
	print("Saving player to %s" % p)
	var s = Serializer.new()
	if !serialize( s ):
		push_warning("Failed serializing player");
	
	s.save_file(p)

func serialize( s: Serializer ) -> bool:
	var chunk_magic = [0x4f, 0x4d, 0x46, 0x49, 0x49, 0x49, 0x53, 0x48]
	
	for m in chunk_magic:
		var b: int = m;
		b = s.serialize_u8( b )
		if b != m:
			push_error( "Broken chunk magic")
			return false

	var version: int = 0x0003;
	version = s.serialize_u16( version )
	if version != 3:
		push_warning("Version not supported ", version)
		return false

	_coins = s.serialize_u32( _coins )
	_lastDistance = s.serialize_u32( _lastDistance )
	_totalDistance = s.serialize_u32( _totalDistance )
	_bestDistance = s.serialize_u32( _bestDistance )
	_playCount = s.serialize_u32( _playCount )
	_isMusicEnabled = s.serialize_bool( _isMusicEnabled )
	_isSoundEnabled = s.serialize_bool( _isSoundEnabled )
	
	return true
		
func coins() -> int:
	return _coins
	
func lastDistance() -> int:
	return _lastDistance
	
func totalDistance() -> int:
	return _totalDistance
	
func bestDistance() -> int:
	return _bestDistance
	
func playCount() -> int:
	return _playCount
	
func isMusicEnabled() -> bool:
	return _isMusicEnabled
	
func isSoundEnabled() -> bool:
	return _isSoundEnabled

func enableMusic():
	if _isMusicEnabled:
		return
	_isMusicEnabled = true
	_isDirty = true

func disableMusic():
	if !_isMusicEnabled:
		return
	_isMusicEnabled = false
	_isDirty = true
	
func enableSound():
	if _isSoundEnabled:
		return
	_isSoundEnabled = true
	_isDirty = true

func disableSound():
	if !_isSoundEnabled:
		return
	_isSoundEnabled = false
	_isDirty = true
			
func give_coins( coins: int ):
	_coins += coins
	
func apply_distance( distance: int ):
	_totalDistance += distance
	_bestDistance = max(_bestDistance, distance)
	_lastDistance = distance;
	
