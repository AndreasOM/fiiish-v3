class_name ZoneSelectionTestScript
extends Node

# Zone selection test harness, runs inside the real game like the other scripts.
#
#   godot --headless --path godot -- --script:"ZoneSelectionTest"                    (all cases)
#   ZONE_SELECTION_TEST_CASE=never_pick godot --headless --path godot -- --script:"ZoneSelectionTest"   (one case)
#
# The case comes from an env var because main.gd only accepts exactly `--script:"Name"` as launch parameter.
#
# Every case returns a list of failure messages (empty = pass). Prints
# ZONE_SELECTION_TEST PASS/FAIL and quits with exit code 0/1.
# The pool depends on the build flavour (demo or full); the full pool also loads user://zones/.

const TEST_SEED: int = 20261118
const PICKS_PER_STEP: int = 2000
const MAX_ZONE_COUNT: int = 60			# the 120 difficulty cap is reached at zone 48
const MAX_TARGET_DIFFICULTY: int = 120	# same cap as ZoneManager._pick_next_zone()
const HIGH_TARGET_DIFFICULTIES: Array[ int ] = [ 32768, 40000, 65535 ]	# at and above bit 15
const MAX_REPORTED_FAILURES: int = 10
const EXPECTED_NEVER_PICK_ZONES: Array[ String ] = [ "8001_Empty", "8002_Trailer" ]

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
