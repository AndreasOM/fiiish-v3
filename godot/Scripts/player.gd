class_name Player

const current_version: int = 14
const oldest_supported_version: int = 3

var _coins: int = 0
var _last_distance: int = 0
var _total_distance: int = 0
var _best_distance: int = 0
var _play_count: int = 0

var _is_dirty: bool = false

## version 4
var _skill_points_gained: int = 0
var _skill_points_used: int = 0

## version 5

var _skills: HashMap = HashMap.new(
	SkillIds.Id.NONE,
	func() -> SkillLevel:
		return SkillLevel.new( 0 )
)

## version 6
var _is_main_menu_enabled: bool = false

## version 7
var _cheats: SerializableHashSet = SerializableHashSet.new( CheatIds.Id.NONE )

## version 8

var _leaderboards: HashMap = HashMap.new(
	LeaderboardTypes.Type.LOCAL_COINS,
	func() -> Leaderboard:
		return Leaderboard.new("NONE")
)

## version 9

var _zone_editor_save: ZoneEditorSave = ZoneEditorSave.new()

## version 10
var _total_coins = 0

## version 11

# version <=11: collected or completed
# version >=12: completed
var _completed_achievements: SerializableArray = SerializableArray.new(
	func() -> SerializableString:
		return SerializableString.new()
)

## version 12
var _collected_achievements: SerializableArray = SerializableArray.new(
	func() -> SerializableString:
		return SerializableString.new()
)

## version 13

var _max_coins: int = 0

## version 14
var _day_streak_start: String = ""	# YYYYMMDD
var _day_streak_length: int = 0

## not serialized
var _first_ranks_on_last_leaderboard_update: Array[ LeaderboardTypes.Type ] = []
var _last_coins = 0
var _last_achievements: Array[ String ] = []

var _prev_best_distance = 0

var _load_suffix: String = ""

static func get_save_path( suffix: String ) -> String:
	return "user://player%s.data" % suffix
	
	
static func load_with_suffix( suffix: String ) -> Player:
	var path = get_save_path( suffix )
	var player = load_from_file( path )
	player._load_suffix = suffix
	return player
	
static func load() -> Player:
	var p = get_save_path( "" )
	return load_from_file( p )

static func load_from_file( path: String ) -> Player:
	print("Loading player from %s" % path)
	var s = Serializer.new()
	if !s.load_file( path ):
		print("Couldn't load player data")
		return Player.new()
		
	var player = Player.new()
	if !player.serialize( s ):
		push_warning("Failed serializing player");
		return Player.new()
		
	return player
	
func reset() -> void:
	_coins = 0
	# ....
	_last_distance = 0
	_total_distance = 0
	_best_distance = 0
	_prev_best_distance = 0
	_play_count = 0
	_skill_points_gained = 0
	_skill_points_used = 0
	_skills.clear()
	_total_coins = 0
	_max_coins = 0
	_completed_achievements.clear()
	_collected_achievements.clear()
	_last_achievements.clear()
	self._day_streak_start = ""
	self._day_streak_length = 0
	self._is_dirty = true
	
func reset_local_leaderboards() -> void:
	_leaderboards.erase( LeaderboardTypes.Type.LOCAL_COINS)
	_leaderboards.erase( LeaderboardTypes.Type.LOCAL_DISTANCE)
	_best_distance = 0
	_prev_best_distance = 0
	_is_dirty = true
	
func save_with_suffix( suffix: String ) -> void:
	var p = get_save_path( suffix )
	print("Saving player to %s" % p)
	var s = Serializer.new()
	if !serialize( s ):
		push_warning("Failed serializing player");
	
	self._load_suffix = suffix
	s.save_file(p)
	
func save() -> void:
	save_with_suffix( self._load_suffix )

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
	_last_distance = s.serialize_u32( _last_distance )
	_total_distance = s.serialize_u32( _total_distance )
	_best_distance = s.serialize_u32( _best_distance )
	_play_count = s.serialize_u32( _play_count )
	
	s.serialize_bool( false )
	s.serialize_bool( false )
	
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

	_is_main_menu_enabled = s.serialize_bool( _is_main_menu_enabled )

	# version 7
	if version < 7:
		return true
		
	_cheats.serialize( s )
	
	# version 8
	if version < 8:
		return true

	_leaderboards.serialize( s )
	
	# version 9:
	if version < 9:
		return true
		
	_zone_editor_save.serialize( s )

	# version 10:
	if version < 10:
		return true
		
	self._total_coins = s.serialize_u32( self._total_coins )
	
	if version < 11:
		return true
		
	self._completed_achievements.serialize( s )

	if version < 12:
		return true
		
	self._collected_achievements.serialize( s )

	if version < 13:
		return true
		
	self._max_coins = s.serialize_u32( self._max_coins )

	if version < 14:
		return true
		
	self._day_streak_start = s.serialize_fixed_string( 8, self._day_streak_start )
	self._day_streak_length = s.serialize_u16( self._day_streak_length )
	
	return true
		
func _get_today_as_yyyymmdd() -> String:
	var utc = true
	var now = Time.get_datetime_dict_from_system( utc )
	
	return "%04d%02d%02d" % [ now["year"], now["month"], now["day"] ]
	

func _days_since_yyyymmdd( date_str: String ) -> int:
	if date_str.length() != 8:
		return -1
		
	var utc = true
	var now = Time.get_datetime_dict_from_system( utc )
	
	now["hour"] = 0
	now["minute"] = 0
	now["second"] = 0
	# :TODO: dst?
	var epoch_now = Time.get_unix_time_from_datetime_dict( now )
	
	var date = {}
	date["year"] = date_str.substr(0,4)
	date["month"] = date_str.substr(4,2)
	date["day"] = date_str.substr(6,2)
	
	var epoch_date = Time.get_unix_time_from_datetime_dict( date )
	
	var delta = ( epoch_now - epoch_date ) / ( 24*60*60 )
	
	
	return delta
	
func _reset_day_streak() -> void:
	var today = self._get_today_as_yyyymmdd()
	
	self._day_streak_length = 1
	self._day_streak_start = today
	
func update_day_streak() -> void:
	if self._day_streak_start.is_empty():
		self._reset_day_streak()
		return
	
	var delta = self._days_since_yyyymmdd( self._day_streak_start )
	delta += 1

	if delta > self._day_streak_length + 1:
		# broken streak
		self._reset_day_streak()
	elif self._day_streak_length != delta:
		# extend streak
		self._day_streak_length = delta
		self._is_dirty = true
	#else: # same day

func day_streak_length() -> int:
	return self._day_streak_length

func total_coins() -> int:
	return self._total_coins
	
func coins() -> int:
	return _coins
	
func last_coins() -> int:
	return _last_coins

func max_coins() -> int:
	return _max_coins

func last_distance() -> int:
	return _last_distance
	
func total_distance() -> int:
	return _total_distance
	
func prev_best_distance() -> int:
	return _prev_best_distance
	
func best_distance() -> int:
	return _best_distance
	
func increase_play_count() -> int:
	self._play_count += 1
	self._is_dirty = true
	return self._play_count

func play_count() -> int:
	return _play_count
	
# sound and music settings were moved to Settings
			
func give_coins( amount: int ):
	_coins += amount
	_last_coins = amount
	self._total_coins += amount
	if self._coins > self._max_coins:
		self._max_coins = self._coins
	
func spend_coins( amount: int, _reason: String ) -> bool:
	if _coins < amount:
		return false
		
	_coins -= amount
	return true
	
func can_afford_coins( amount: int ) -> bool:
	return _coins >= amount	
	
func apply_distance( distance: int ) -> void:
	_total_distance += distance
	_prev_best_distance = _best_distance
	_best_distance = max(_best_distance, distance)
	_last_distance = distance;
	
func give_skill_points( amount: int, _reason: String ) -> void:
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

func get_total_skill_levels() -> int:
	var total = 0
	for s in self._skills.keys():
		var l = self._skills.get_entry( s )
		total += l.get_value()
	return total
	
func get_skill_level( id: SkillIds.Id ) -> int:
	return _skills.get_entry( id, SkillLevel.new( 0 ) ).get_value()
	
func set_skill_level( id: SkillIds.Id, level: int ) -> void:
	_skills.set_entry( id, SkillLevel.new( level ) )
	
func reset_skills() -> void:
	_skills.clear()
	_skill_points_used = 0


# version 6

func is_main_menu_enabled() -> bool:
	return _is_main_menu_enabled

func enable_main_menu() -> void:
	if _is_main_menu_enabled:
		return
	_is_main_menu_enabled = true
	_is_dirty = true

func disable_main_menu() -> void:
	if !_is_main_menu_enabled:
		return
	_is_main_menu_enabled = false
	_is_dirty = true

func is_cheat_enabled( id: CheatIds.Id ) -> bool:
	return _cheats.has( id )
	
func enable_cheat( id: CheatIds.Id ) -> void:
	self._cheats.add_entry( id )

func disable_cheat( id: CheatIds.Id ) -> void:
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

func get_zone_editor_save() -> ZoneEditorSave:
	return self._zone_editor_save

func add_completed_achievements( achievements: Array[ String ] ) -> void:
	self._last_achievements = achievements
	for a in achievements:
		var s = SerializableString.new( a )
		if !self._completed_achievements.has( s ):
			self._completed_achievements.push_back( s )
			self._is_dirty = true

func reset_achievements() -> void:
	self._completed_achievements.clear()
	self._collected_achievements.clear()
	self._is_dirty = true
	
func completed_achievements() -> Array[ String ]:
	var r: Array[ String ] = []
	for a in self._completed_achievements.iter():
		var s = a.to_string()
		if s != null:
			r.push_back( s )
	
	return r

func collected_achievements() -> Array[ String ]:
	var r: Array[ String ] = []
	for a in self._collected_achievements.iter():
		var s = a.to_string()
		if s != null:
			r.push_back( s )
	
	return r

func collect_achievement( id: String ) -> bool:
	var s_id = SerializableString.new( id )
	var found_id = self._completed_achievements.take( s_id )
	if found_id == null:
		return false
	if self._collected_achievements.has( s_id ):
		return false
		
	self._collected_achievements.push_back( s_id )
	
	return true
