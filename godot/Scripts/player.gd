class_name Player

const current_version: int = 8
const oldest_supported_version: int = 3

var _coins: int = 0
var _lastDistance: int = 0
var _totalDistance: int = 0
var _bestDistance: int = 0
var _playCount: int = 0
var _isMusicEnabled: bool = true
var _isSoundEnabled: bool = true
var _isDirty: bool = false

## version 4
var _skill_points_gained: int = 0
var _skill_points_used: int = 0

## version 5

var _skills = {
}

## version 6
var _isMainMenuEnabled: bool = false

## version 7
var _cheats: Dictionary[ CheatIds.Id, bool ] = {}

## version 8
var _leaderboards: Dictionary[ LeaderboardTypes.Type, Leaderboard ] = {}

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
	
func reset():
	_coins = 0
	# ....
	_lastDistance = 0
	_totalDistance = 0
	_bestDistance = 0
	_playCount = 0
	_skill_points_gained = 0
	_skill_points_used = 0
	_skills = {}
	
func reset_local_leaderboards():
	_leaderboards.erase( LeaderboardTypes.Type.LOCAL_COINS)
	_leaderboards.erase( LeaderboardTypes.Type.LOCAL_DISTANCE)
	_bestDistance = 0
	_isDirty = true
	
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

	var version: int = current_version;
	version = s.serialize_u16( version )
	if version < oldest_supported_version:
		push_warning("Version not supported ", version)
		return false

	_coins = s.serialize_u32( _coins )
	_lastDistance = s.serialize_u32( _lastDistance )
	_totalDistance = s.serialize_u32( _totalDistance )
	_bestDistance = s.serialize_u32( _bestDistance )
	_playCount = s.serialize_u32( _playCount )
	_isMusicEnabled = s.serialize_bool( _isMusicEnabled )
	_isSoundEnabled = s.serialize_bool( _isSoundEnabled )
	
	# version 4
	if version < 4:
		return true
	
	_skill_points_gained = s.serialize_u32( _skill_points_gained )
	_skill_points_used = s.serialize_u32( _skill_points_used )

	# version 5
	if version < 5:
		return true
		
	var keys = _skills.keys()
	var number_of_skills = keys.size()
	number_of_skills = s.serialize_u16( number_of_skills )
	
	for idx in range(0,number_of_skills):
		var k = SkillEffectIds.Id.NONE
		var v = 0
		if idx < keys.size():
			k = keys[ idx ]
			v = _skills.get( k, 0 )
		k = s.serialize_u32( k )
		v = s.serialize_u16( v )
		
		_skills[ k ] = v
	
	# :TODO: cleanup old skills
#	reset_skills()
#	_skill_points_gained = 0

	# version 6
	if version < 6:
		return true

	_isMainMenuEnabled = s.serialize_bool( _isMainMenuEnabled )

	# version 7
	if version < 7:
		return true
		
	var cheat_keys = _cheats.keys()
	var number_of_cheats = cheat_keys.size()
	number_of_cheats = s.serialize_u16( number_of_cheats )
	
	for idx in range(0,number_of_cheats):
		var k = CheatIds.Id.NONE
		if idx < cheat_keys.size():
			k = cheat_keys[ idx ]
		# print("CHEAT: %d %d/%d" % [ k, idx, number_of_cheats ] )
		k = s.serialize_u32( k )
		# print("CHEAT: %d %d/%d" % [ k, idx, number_of_cheats ] )
		_cheats[ k ] = true

	# version 8
	if version < 8:
		return true

	var leaderboards_keys = _leaderboards.keys()
	var number_of_leaderboards = leaderboards_keys.size()
	number_of_leaderboards = s.serialize_u16( number_of_leaderboards )
			
	for idx in range(0,number_of_leaderboards):
		var k = LeaderboardTypes.Type.NONE
		var v = Leaderboard.new("NONE")
		if idx < keys.size():
			k = leaderboards_keys[ idx ]
			v = _leaderboards.get( k, 0 )
		k = s.serialize_u32( k )
		v.serialize( s )
		
		_leaderboards[ k ] = v
	
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
			
func give_coins( amount: int ):
	_coins += amount
	
func spend_coins( amount: int, _reason: String ) -> bool:
	if _coins < amount:
		return false
		
	_coins -= amount
	return true
	
func can_afford_coins( amount: int ) -> bool:
	return _coins >= amount	
	
func apply_distance( distance: int ):
	_totalDistance += distance
	_bestDistance = max(_bestDistance, distance)
	_lastDistance = distance;
	
func give_skill_points( amount: int, _reason: String ):
	_skill_points_gained += amount
	
func available_skill_points() -> int:
	return _skill_points_gained - _skill_points_used

func gained_skill_points() -> int:
	return _skill_points_gained
	
func use_skill_points( amount: int, _reason: String ) -> bool:
	if	amount > available_skill_points():
		return false
		
	_skill_points_used += amount
	
	return true
	
func get_skill_level( id: SkillIds.Id ) -> int:
	return _skills.get( id, 0 )
	
func set_skill_level( id: SkillIds.Id, level: int ):
	_skills[ id ] = level
	
func reset_skills():
	_skills = {}
	_skill_points_used = 0


# version 6

func isMainMenuEnabled() -> bool:
	return _isMainMenuEnabled

func enableMainMenu():
	if _isMainMenuEnabled:
		return
	_isMainMenuEnabled = true
	_isDirty = true

func disableMainMenu():
	if !_isMainMenuEnabled:
		return
	_isMainMenuEnabled = false
	_isDirty = true

func isCheatEnabled( id: CheatIds.Id ) -> bool:
	return _cheats.has( id )
	
func enableCheat( id: CheatIds.Id ):
	self._cheats[ id ] = true

func disableCheat( id: CheatIds.Id ):
	self._cheats.erase( id )
	

func get_leaderboard( type: LeaderboardTypes.Type ) -> Leaderboard:
	return self._leaderboards.get( type )
	
func update_leaderboards( coins: int, distance: int ):
	# var dt = Time.get_datetime_dict_from_system()
	# var p = "%dddd" % [ dt[ "year"]]
	var p = Time.get_datetime_string_from_system( false, true )
	var lc = self._leaderboards.get_or_add( LeaderboardTypes.Type.LOCAL_COINS, Leaderboard.new( "Local Coins", 20 ) )
	lc.add_entry( p, coins )

	var ld = self._leaderboards.get_or_add( LeaderboardTypes.Type.LOCAL_DISTANCE, Leaderboard.new( "Local Distance", 20 ) )
	ld.add_entry( p, distance )
