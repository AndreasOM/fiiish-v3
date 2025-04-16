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

#var _skills = {
#}

var _skills: HashMap = HashMap.new(
	SkillIds.Id.NONE,
	func() -> SkillLevel:
		return SkillLevel.new( 0 )
)

## version 6
var _isMainMenuEnabled: bool = false

## version 7
var _cheats: SerializableHashSet = SerializableHashSet.new( CheatIds.Id.NONE )

## version 8

var _leaderboards: HashMap = HashMap.new(
	LeaderboardTypes.Type.LOCAL_COINS,
	func() -> Leaderboard:
		return Leaderboard.new("NONE")
)

## not serialized
var _first_ranks_on_last_leaderboard_update: Array[ LeaderboardTypes.Type ] = []
var _lastCoins = 0

var _prev_best_distance = 0

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
	_prev_best_distance = 0
	_playCount = 0
	_skill_points_gained = 0
	_skill_points_used = 0
	_skills.clear()
	
func reset_local_leaderboards():
	_leaderboards.erase( LeaderboardTypes.Type.LOCAL_COINS)
	_leaderboards.erase( LeaderboardTypes.Type.LOCAL_DISTANCE)
	_bestDistance = 0
	_prev_best_distance = 0
	_isDirty = true
	
func save():
	var p = get_save_path()
	print("Saving player to %s" % p)
	var s = Serializer.new()
	if !serialize( s ):
		push_warning("Failed serializing player");
	
	s.save_file(p)

func serialize( s: Serializer ) -> bool:

	if !s.serialize_chunk_magic( [0x4f, 0x4d, 0x46, 0x49, 0x49, 0x49, 0x53, 0x48] ):
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
		
	_skills.serialize( s )
	
	# version 6
	if version < 6:
		return true

	_isMainMenuEnabled = s.serialize_bool( _isMainMenuEnabled )

	# version 7
	if version < 7:
		return true
		
	_cheats.serialize( s )
	
	# version 8
	if version < 8:
		return true

	_leaderboards.serialize( s )
	
	return true
		
func coins() -> int:
	return _coins
	
func lastCoins() -> int:
	return _lastCoins

func lastDistance() -> int:
	return _lastDistance
	
func totalDistance() -> int:
	return _totalDistance
	
func prev_best_distance() -> int:
	return _prev_best_distance
	
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
	_lastCoins = amount
	
func spend_coins( amount: int, _reason: String ) -> bool:
	if _coins < amount:
		return false
		
	_coins -= amount
	return true
	
func can_afford_coins( amount: int ) -> bool:
	return _coins >= amount	
	
func apply_distance( distance: int ):
	_totalDistance += distance
	_prev_best_distance = _bestDistance
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
	return _skills.get_entry( id, SkillLevel.new( 0 ) ).get_value()
	
func set_skill_level( id: SkillIds.Id, level: int ):
	_skills.set_entry( id, SkillLevel.new( level ) )
	
func reset_skills():
	_skills.clear()
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
	self._cheats.add_entry( id )

func disableCheat( id: CheatIds.Id ):
	self._cheats.erase( id )
	

func get_leaderboard( type: LeaderboardTypes.Type ) -> Leaderboard:
	return self._leaderboards.get_entry( type )
	
func update_leaderboards( new_coins: int, distance: int ) -> Array[ LeaderboardTypes.Type ]:
	# var dt = Time.get_datetime_dict_from_system()
	# var p = "%dddd" % [ dt[ "year"]]
	var first_ranks: Array[ LeaderboardTypes.Type ] = []
	var p = Time.get_datetime_string_from_system( false, true )
	var lc = self._leaderboards.get_or_add( LeaderboardTypes.Type.LOCAL_COINS, Leaderboard.new( "Local Coins", 20 ) )
	var coin_rank = lc.add_entry( p, new_coins )
	if coin_rank == 0:
		first_ranks.push_back( LeaderboardTypes.Type.LOCAL_COINS )

	var ld = self._leaderboards.get_or_add( LeaderboardTypes.Type.LOCAL_DISTANCE, Leaderboard.new( "Local Distance", 20 ) )
	var distance_rank = ld.add_entry( p, distance )
	if distance_rank == 0:
		first_ranks.push_back( LeaderboardTypes.Type.LOCAL_DISTANCE )

	self._first_ranks_on_last_leaderboard_update = first_ranks
	return first_ranks

func get_first_ranks_on_last_leaderboard_update() -> Array[ LeaderboardTypes.Type ]:
	return self._first_ranks_on_last_leaderboard_update
