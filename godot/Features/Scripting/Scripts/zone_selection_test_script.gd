class_name ZoneSelectionTestScript
extends Node

# Zone selection test harness, runs inside the real game like the other scripts.
#
# Launch parameters, like the other scripts (editor launch control sets them as main_run_args):
#   --script:"ZoneSelectionTest" --no-user-zones
#
# --no-user-zones tests the shipped zones only (same pool on every machine). Without it the full pool
# also loads user://zones/. The pool also depends on the build flavour (demo or full).
# Set the env var ZONE_SELECTION_TEST_CASE (e.g. never_pick) to run a single case.
#
# Every case returns a list of failure messages (empty = pass). Prints
# ZONE_SELECTION_TEST PASS/FAIL and quits with exit code 0/1.

const TEST_SEED: int = 20261118
const PICKS_PER_STEP: int = 2000
const MAX_ZONE_COUNT: int = 60			# the 120 difficulty cap is reached at zone 48
const MAX_TARGET_DIFFICULTY: int = 120	# same cap as ZoneManager._pick_next_zone()
const HIGH_TARGET_DIFFICULTIES: Array[ int ] = [ 32768, 40000, 65535 ]	# at and above bit 15
const MAX_REPORTED_FAILURES: int = 10
const EXPECTED_NEVER_PICK_ZONES: Array[ String ] = [ "8001_Empty", "8002_Trailer" ]
const RECENT_WINDOW: int = 8			# same as ZoneManager.RECENT_ZONES_MAX
const REPEAT_PICKS: int = 20000
const REPEAT_TARGETS: Array[ int ] = [ 5, 20, 60, 120 ]

var _zone_manager: ZoneManager = null
var _zone_config_manager: ZoneConfigManager = null

func run( script_manager: ScriptManager ) -> bool:
	print("ZoneSelectionTest - run()")
	self._zone_manager = script_manager.game.zone_manager
	self._zone_config_manager = script_manager.game.get_game_manager().get_zone_config_manager()

	# let the game finish starting up. The cases themselves never await,
	# so nothing else touches the zone history while they run.
	await get_tree().process_frame

	var cases: Dictionary[ String, Callable ] = {
		"never_pick": self._case_never_pick,
		"no_repeat": self._case_no_repeat,
		"small_pool": self._case_small_pool,
		"player_save": self._case_player_save,
	}

	var selected = self._get_selected_case()
	if selected != "" && !cases.has( selected ):
		push_error( "ZoneSelectionTest - unknown case '%s' (known: %s)" % [ selected, ", ".join( cases.keys() ) ] )
		get_tree().quit( 1 )
		return false

	var all_ok = true
	for case_name in cases:
		if selected != "" && selected != case_name:
			continue
		seed( TEST_SEED )
		var failures: Array[ String ] = cases[ case_name ].call()
		if failures.is_empty():
			print("ZoneSelectionTest - case %s: PASS" % case_name)
		else:
			all_ok = false
			print("ZoneSelectionTest - case %s: FAIL (%d)" % [ case_name, failures.size() ])
			for f in failures:
				print("ZoneSelectionTest -   %s" % f)

	print( "ZONE_SELECTION_TEST PASS" if all_ok else "ZONE_SELECTION_TEST FAIL" )
	get_tree().quit( 0 if all_ok else 1 )
	return all_ok

func _get_selected_case() -> String:
	return OS.get_environment( "ZONE_SELECTION_TEST_CASE" )

func _add_failure( failures: Array[ String ], message: String ) -> void:
	if failures.size() < MAX_REPORTED_FAILURES:
		failures.push_back( message )
	elif failures.size() == MAX_REPORTED_FAILURES:
		failures.push_back( "... more failures not shown" )

func _check_pick( failures: Array[ String ], where: String, zone: NewZone ) -> void:
	if zone == null:
		self._add_failure( failures, "%s: no zone picked" % where )
	elif zone.is_never_pick():
		self._add_failure( failures, "%s: picked never-pick zone %s" % [ where, zone.name ] )

# Zones with the never-pick bit must never come out of the automatic picker,
# but scripts can still spawn them by name.
func _case_never_pick() -> Array[ String ]:
	var failures: Array[ String ] = []

	# The pool must really contain never-pick zones, else this case passes without testing anything.
	var never_pick_names: Array[ String ] = []
	var normal_count = 0
	for i in range( self._zone_config_manager.zone_count() ):
		var z = self._zone_config_manager.get_zone( i )
		if z.is_never_pick():
			never_pick_names.push_back( z.name )
		else:
			normal_count += 1
	print("ZoneSelectionTest - never_pick: %d pickable zones, never-pick zones: %s" % [ normal_count, never_pick_names ])

	if normal_count == 0:
		self._add_failure( failures, "pool has no pickable zones" )
		return failures
	if !FeatureTags.has_feature( "demo" ):
		for expected in EXPECTED_NEVER_PICK_ZONES:
			if !never_pick_names.has( expected ):
				self._add_failure( failures, "%s is not flagged never-pick" % expected )

	# The real picker: real blocked list and real difficulty formula.
	# The game always has the start zone in the history, so it starts at 1.
	var saved_history = self._zone_manager._zone_history
	for zn in range( 1, MAX_ZONE_COUNT + 1 ):
		var history = []
		history.resize( zn )
		history.fill( "test" )
		self._zone_manager._zone_history = history
		for n in range( PICKS_PER_STEP ):
			self._check_pick( failures, "zone count %d" % zn, self._zone_manager._pick_next_zone() )
	self._zone_manager._zone_history = saved_history

	# The flag is the only thing keeping those zones out: nothing blocked by name.
	# Starts at 1, an empty pool would not terminate in pick_next_zone().
	for d in range( 1, MAX_TARGET_DIFFICULTY + 1 ):
		for n in range( PICKS_PER_STEP ):
			self._check_pick( failures, "difficulty %d, nothing blocked" % d, self._zone_config_manager.pick_next_zone( [], d ) )

	# Targets above the flagged zones' difficulty: the distance rule (difficulty <= target) alone no longer
	# keeps never-pick zones out, only the flag does. This is what makes the check independent of the 120 cap.
	for d in HIGH_TARGET_DIFFICULTIES:
		for n in range( PICKS_PER_STEP ):
			self._check_pick( failures, "difficulty %d (above the cap), nothing blocked" % d, self._zone_config_manager.pick_next_zone( [], d ) )

	# Scripts still reach them by name.
	for zone_name in never_pick_names:
		var idx = self._zone_config_manager.find_zone_index_by_name( zone_name )
		if idx < 0 || self._zone_config_manager.get_zone( idx ).name != zone_name:
			self._add_failure( failures, "%s not found by name" % zone_name )

	return failures

# pickable zone names for a target difficulty (not never-pick, not too difficult)
func _eligible_names( difficulty: int ) -> Array[ String ]:
	var names: Array[ String ] = []
	for i in range( self._zone_config_manager.zone_count() ):
		var z = self._zone_config_manager.get_zone( i )
		if !z.is_never_pick() && z.difficulty <= difficulty:
			names.push_back( z.name )
	return names

# Feeds the recent list back like ZoneManager does. While the eligible pool is big enough
# the picker must keep the whole window apart; with a smaller pool at least the previous zone.
func _case_no_repeat() -> Array[ String ]:
	var failures: Array[ String ] = []
	var tested = 0
	for d in REPEAT_TARGETS:
		var pool = self._eligible_names( d ).size()
		print("ZoneSelectionTest - no_repeat: target %d has %d eligible zones" % [ d, pool ])
		if pool < 4:
			continue	# too small to guarantee anything, small_pool covers that
		tested += 1
		var recent: Array[ String ] = []
		for n in range( REPEAT_PICKS ):
			var zone = self._zone_config_manager.pick_next_zone( [], d, recent )
			self._check_pick( failures, "target %d" % d, zone )
			if zone == null:
				break
			if pool >= RECENT_WINDOW + 3 && recent.has( zone.name ):
				self._add_failure( failures, "target %d: %s repeated within the last %d (pool %d)" % [ d, zone.name, RECENT_WINDOW, pool ] )
			elif !recent.is_empty() && recent.back() == zone.name:
				self._add_failure( failures, "target %d: %s twice in a row (pool %d)" % [ d, zone.name, pool ] )
			recent.push_back( zone.name )
			while recent.size() > RECENT_WINDOW:
				recent.pop_front()
	if tested == 0:
		self._add_failure( failures, "no target difficulty has a big enough pool" )
	return failures

# Tiny pools must neither hang nor come back empty while a zone is pickable.
func _case_small_pool() -> Array[ String ]:
	var failures: Array[ String ] = []
	var eligible = self._eligible_names( MAX_TARGET_DIFFICULTY )
	if eligible.size() < 2:
		self._add_failure( failures, "pool too small to test (%d)" % eligible.size() )
		return failures

	for keep in [ 1, 2, 3 ]:
		if keep > eligible.size():
			continue
		var blocked: Array[ String ] = []
		for i in range( self._zone_config_manager.zone_count() ):
			var name = self._zone_config_manager.get_zone( i ).name
			if eligible.find( name ) >= keep:
				blocked.push_back( name )
			elif eligible.find( name ) < 0:
				blocked.push_back( name )
		var recent: Array[ String ] = []
		for n in range( 500 ):
			var zone = self._zone_config_manager.pick_next_zone( blocked, MAX_TARGET_DIFFICULTY, recent )
			self._check_pick( failures, "pool of %d" % keep, zone )
			if zone == null:
				break
			recent.push_back( zone.name )
			while recent.size() > RECENT_WINDOW:
				recent.pop_front()

	# nothing pickable: must come back with null, not loop
	var all_blocked: Array[ String ] = []
	for i in range( self._zone_config_manager.zone_count() ):
		all_blocked.push_back( self._zone_config_manager.get_zone( i ).name )
	if self._zone_config_manager.pick_next_zone( all_blocked, MAX_TARGET_DIFFICULTY, [] ) != null:
		self._add_failure( failures, "picked a zone with everything blocked" )
	return failures

# Player save v15 added the recent zones list. The v14 fixture (godot-saves/) must still load, with an empty list.
func _case_player_save() -> Array[ String ]:
	var failures: Array[ String ] = []
	var fixture = ProjectSettings.globalize_path( "res://" ).path_join( "../godot-saves/player-version-14.data" ).simplify_path()
	if !FileAccess.file_exists( fixture ):
		self._add_failure( failures, "fixture missing: %s" % fixture )
		return failures

	var old = Player.load_from_file( fixture )
	if old.coins() != 1276:
		self._add_failure( failures, "v14 fixture: coins %d, expected 1276 (did loading break?)" % old.coins() )
	if !old.recent_zones().is_empty():
		self._add_failure( failures, "v14 fixture: recent zones %s, expected empty" % [ old.recent_zones() ] )

	# roundtrip as the current version, other fields must survive
	var zones: Array[ String ] = [ "3001_A", "5002_PinkAndPurple", "D0006_EasyGoing3" ]
	old.set_recent_zones( zones )
	var suffix = "_zone_selection_test"
	old.save_with_suffix( suffix )
	var path = Player.get_save_path( suffix )
	var reloaded = Player.load_with_suffix( suffix )
	DirAccess.remove_absolute( path )
	if reloaded.recent_zones() != zones:
		self._add_failure( failures, "roundtrip: recent zones %s, expected %s" % [ reloaded.recent_zones(), zones ] )
	if reloaded.coins() != 1276:
		self._add_failure( failures, "roundtrip: coins %d, expected 1276" % reloaded.coins() )
	return failures
