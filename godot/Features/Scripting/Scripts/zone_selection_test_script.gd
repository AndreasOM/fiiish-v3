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
const RECENT_WINDOW: int = Player.MAX_RECENT_ZONES
const REPEAT_PICKS: int = 5000
const REPEAT_TARGETS: Array[ int ] = [ 2, 5, 12, 20, 40, 60, 70, 90, 120 ]

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
		"remember_picked_only": self._case_remember_picked_only,
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

# Names of the different zones in the picker's difficulty band for a target (no recent list involved).
func _band_names( blocked: Array[ String ], difficulty: int ) -> Array[ String ]:
	var names: Array[ String ] = []
	for i in self._zone_config_manager._collect_candidates( blocked, difficulty ):
		var zone_name = self._zone_config_manager.get_zone( i ).name
		if !names.has( zone_name ):
			names.push_back( zone_name )
	return names

# Picks `picks` zones for one target and keeps the list of recent zones like ZoneManager does. The list
# goes to the picker only with use_recent. Returns counters: picks done, picks that were among the recent
# zones ("within_window"), picks equal to the previous one ("back_to_back") and the summed difficulty.
# With use_recent it also adds failures: for a pick outside the band, for a back to back repeat while the
# band has 2 or more zones, and for a repeat within the window while the band is big enough to avoid it.
func _run_picks( failures: Array[ String ], where: String, blocked: Array[ String ], difficulty: int, picks: int, use_recent: bool ) -> Dictionary:
	var band = self._band_names( blocked, difficulty )
	var stats = { "picks": 0, "within_window": 0, "back_to_back": 0, "difficulty_sum": 0 }
	var recent: Array[ String ] = []
	var no_recent: Array[ String ] = []
	for n in range( picks ):
		var zone = self._zone_config_manager.pick_next_zone( blocked, difficulty, recent if use_recent else no_recent )
		self._check_pick( failures, where, zone )
		if zone == null:
			break
		var within_window = recent.has( zone.name )
		var back_to_back = !recent.is_empty() && recent.back() == zone.name
		stats[ "picks" ] += 1
		stats[ "difficulty_sum" ] += zone.difficulty
		if within_window:
			stats[ "within_window" ] += 1
		if back_to_back:
			stats[ "back_to_back" ] += 1
		if use_recent:
			if !band.has( zone.name ):
				self._add_failure( failures, "%s: %s is outside the difficulty band %s" % [ where, zone.name, band ] )
			if back_to_back && band.size() >= 2:
				self._add_failure( failures, "%s: %s twice in a row (band of %d)" % [ where, zone.name, band.size() ] )
			if within_window && band.size() >= RECENT_WINDOW + ZoneConfigManager.MIN_DISTINCT_ZONES:
				self._add_failure( failures, "%s: %s repeated within the last %d (band of %d)" % [ where, zone.name, RECENT_WINDOW, band.size() ] )
		recent.push_back( zone.name )
		while recent.size() > RECENT_WINDOW:
			recent.pop_front()
	return stats

func _percent( part: int, total: int ) -> float:
	return 100.0 * part / max( 1, total )

# The recent list must only change which zone of the difficulty band comes, never the band itself:
# a repeat is better than a zone of the wrong difficulty. Inside the band the previous zone must not
# come again while there is another one. Prints a report per target, with and without the recent list.
func _case_no_repeat() -> Array[ String ]:
	var failures: Array[ String ] = []
	var no_blocked: Array[ String ] = []
	var exercised = false
	for d in REPEAT_TARGETS:
		var band_size = self._band_names( no_blocked, d ).size()
		if band_size >= 2:
			exercised = true
		var plain = self._run_picks( failures, "target %d" % d, no_blocked, d, REPEAT_PICKS, false )
		var avoiding = self._run_picks( failures, "target %d" % d, no_blocked, d, REPEAT_PICKS, true )
		print("ZoneSelectionTest - no_repeat: target %3d, band of %2d zones | within last %d: %5.1f%% -> %5.1f%% | back to back: %5.1f%% -> %5.1f%% | mean difficulty: %5.1f -> %5.1f" % [
			d, band_size, RECENT_WINDOW,
			self._percent( plain[ "within_window" ], plain[ "picks" ] ), self._percent( avoiding[ "within_window" ], avoiding[ "picks" ] ),
			self._percent( plain[ "back_to_back" ], plain[ "picks" ] ), self._percent( avoiding[ "back_to_back" ], avoiding[ "picks" ] ),
			float( plain[ "difficulty_sum" ] ) / max( 1, plain[ "picks" ] ), float( avoiding[ "difficulty_sum" ] ) / max( 1, avoiding[ "picks" ] ),
		])
	if !exercised:
		self._add_failure( failures, "no target has a band of 2 or more zones" )
	return failures

# Tiny pools must neither hang nor come back empty while a zone is pickable,
# and must still not repeat back to back when the band holds two zones.
func _case_small_pool() -> Array[ String ]:
	var failures: Array[ String ] = []
	var eligible = self._eligible_names( MAX_TARGET_DIFFICULTY )
	if eligible.size() < 3:
		self._add_failure( failures, "pool too small to test (%d)" % eligible.size() )
		return failures

	var exercised = false
	for keep in [ 1, 2, 3 ]:
		var blocked: Array[ String ] = []
		for i in range( self._zone_config_manager.zone_count() ):
			var zone_name = self._zone_config_manager.get_zone( i ).name
			if eligible.find( zone_name ) < 0 || eligible.find( zone_name ) >= keep:
				blocked.push_back( zone_name )
		var band_size = self._band_names( blocked, MAX_TARGET_DIFFICULTY ).size()
		if band_size >= 2:
			exercised = true
		print("ZoneSelectionTest - small_pool: pool of %d, band of %d zones" % [ keep, band_size ])
		self._run_picks( failures, "pool of %d" % keep, blocked, MAX_TARGET_DIFFICULTY, 500, true )
	if !exercised:
		self._add_failure( failures, "no small pool has a band of 2 or more zones" )

	# nothing pickable: must come back with null, not loop
	var all_blocked: Array[ String ] = []
	for i in range( self._zone_config_manager.zone_count() ):
		all_blocked.push_back( self._zone_config_manager.get_zone( i ).name )
	if self._zone_config_manager.pick_next_zone( all_blocked, MAX_TARGET_DIFFICULTY, [] ) != null:
		self._add_failure( failures, "picked a zone with everything blocked" )
	return failures

# Player save v15 added the recent zones list. The v14 fixture (godot-saves/) must still load, with an empty list.
# The list must keep only the latest Player.MAX_RECENT_ZONES names and survive a save and load.
# Does not cover the `version < 15` gate in Player.serialize(): the Serializer returns zeros past the
# end of the data, so the v14 fixture loads the same with or without the gate.
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

	# more pushes than the list holds: only the latest names stay, oldest first
	var pushed = Player.MAX_RECENT_ZONES + 2
	var zones: Array[ String ] = []
	for i in range( pushed ):
		old.push_recent_zone( "zone_%02d" % i )
		if i >= pushed - Player.MAX_RECENT_ZONES:
			zones.push_back( "zone_%02d" % i )
	if old.recent_zones() != zones:
		self._add_failure( failures, "after %d pushes: recent zones %s, expected %s" % [ pushed, old.recent_zones(), zones ] )

	# roundtrip as the current version, other fields must survive
	var suffix = "_zone_selection_test"
	old.save_with_suffix( suffix )
	var path = Player.get_save_path( suffix )
	var reloaded = Player.load_with_suffix( suffix )
	DirAccess.remove_absolute( path )
	if reloaded.recent_zones() != zones:
		self._add_failure( failures, "roundtrip: recent zones %s, expected %s" % [ reloaded.recent_zones(), zones ] )
	if reloaded.coins() != 1276:
		self._add_failure( failures, "roundtrip: coins %d, expected 1276" % reloaded.coins() )

	reloaded.clear_recent_zones()
	if !reloaded.recent_zones().is_empty():
		self._add_failure( failures, "after clear: recent zones %s, expected empty" % [ reloaded.recent_zones() ] )
	return failures

# Goes through ZoneManager.spawn_zone(): a forced zone (the start zone) must not land in the player's
# recent zones, a zone the picker chose must. The player owns the list, so a list emptied behind
# ZoneManager's back must stay empty. Really spawns three zones, then puts everything back.
func _case_remember_picked_only() -> Array[ String ]:
	var failures: Array[ String ] = []
	var zm = self._zone_manager
	var zcm = self._zone_config_manager
	var player = zm.game_manager.game.get_player()

	var start_zone = "D0000_Start" if FeatureTags.has_feature( "demo" ) else "0000_ILoveFiiish"
	if zcm.find_zone_index_by_name( start_zone ) < 0:
		self._add_failure( failures, "start zone %s not in the pool" % start_zone )
		return failures

	var saved_recent = player.recent_zones()
	var saved_history = zm._zone_history.duplicate()
	var saved_next = zcm._next_zones.duplicate()
	var saved_zone = zm._current_zone
	var saved_progress = zm.current_zone_progress
	var saved_autospawn = zm._autospawn_on_zone_end

	# forced zone
	zcm.clear_next_zones()
	zcm.push_next_zone_by_name( start_zone )
	if !zm.spawn_zone( false ):
		self._add_failure( failures, "forced zone did not spawn" )
	elif zm.get_current_zone_name() != start_zone:
		self._add_failure( failures, "forced zone: got %s, expected %s" % [ zm.get_current_zone_name(), start_zone ] )
	if player.recent_zones() != saved_recent:
		self._add_failure( failures, "forced zone changed the recent zones: %s -> %s" % [ saved_recent, player.recent_zones() ] )

	# picked zone
	if !zm.spawn_zone( false ):
		self._add_failure( failures, "picked zone did not spawn" )
	else:
		var picked = zm.get_current_zone_name()
		var expected = saved_recent.duplicate()
		expected.push_back( picked )
		while expected.size() > RECENT_WINDOW:
			expected.pop_front()
		if player.recent_zones() != expected:
			self._add_failure( failures, "picked zone %s: recent zones %s, expected %s" % [ picked, player.recent_zones(), expected ] )

	# picked zone after the player's list was emptied (e.g. player reset, kids mode switch)
	player.clear_recent_zones()
	if !zm.spawn_zone( false ):
		self._add_failure( failures, "picked zone after clear did not spawn" )
	else:
		var expected_after_clear: Array[ String ] = [ zm.get_current_zone_name() ]
		if player.recent_zones() != expected_after_clear:
			self._add_failure( failures, "picked zone after clear: recent zones %s, expected %s" % [ player.recent_zones(), expected_after_clear ] )

	# put everything back
	zm.cleanup()
	zm._zone_history = saved_history
	zm._current_zone = saved_zone
	zm.current_zone_progress = saved_progress
	zm._autospawn_on_zone_end = saved_autospawn
	zcm._next_zones = saved_next
	player.clear_recent_zones()
	for zone_name in saved_recent:
		player.push_recent_zone( zone_name )
	return failures
