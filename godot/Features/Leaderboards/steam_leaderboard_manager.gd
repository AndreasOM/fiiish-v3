class_name SteamLeaderboardManager
extends Node

var _leaderboards: Dictionary[ String, SteamLeaderboard ] = {}

const LEADERBOARD_MAPPINGS = {
	LeaderboardTypes.Type.LOCAL_COINS:	[ 
											"dev_max_single_run_coins",
										],
	LeaderboardTypes.Type.LOCAL_DISTANCE:	[ 
											"dev_max_single_run_distance",
										],
}

var _pending_leaderboards_to_find: Array[ String ] = []

var _find_leaderboard_in_flight: bool = false

func _ready() -> void:
	if SteamWrapper.is_available():
		var steam = SteamWrapper.get_steam()
		if steam.isSteamRunning():
			steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
			steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)

func send_highscore(leaderboard_type: LeaderboardTypes.Type, value: float) -> void:
	var leaderboard_names = self.LEADERBOARD_MAPPINGS.get( leaderboard_type, [] )
	
	for leaderboard_name in leaderboard_names:
		if !self._leaderboards.has( leaderboard_name ):
			self._leaderboards[ leaderboard_name ] = SteamLeaderboard.new( leaderboard_name )
			self._pending_leaderboards_to_find.push_back( leaderboard_name )
#			print("STEAM: Created new leaderboard for %s" % [ leaderboard_name ] )
		
		var l = self._leaderboards.get( leaderboard_name, null )
		if l == null:
			push_warning("Leaderboard does not exist after creation: %s" % [ leaderboard_name ] )
			return
		
		l.send_highscore( value )
		
#	if SteamWrapper.is_available():
#		var steam = SteamWrapper.get_steam()
#		if steam.isSteamRunning():
#			for c in steam.leaderboard_find_result.get_connections():
#				print("STEAM: Connection %s" % [ str(c) ] )

func _on_leaderboard_find_result(new_handle: int, was_found: int) -> void:
#	print("STEAM: _on_leaderboard_find_result %d" % [ new_handle ] )
	self._find_leaderboard_in_flight = false
	for l in self._leaderboards.values():
		l._on_leaderboard_find_result( new_handle, was_found )
	
func _on_leaderboard_score_uploaded(success: int, this_handle: int, this_score: Dictionary) -> void:
	for l in self._leaderboards.values():
		l._on_leaderboard_score_uploaded( success, this_handle, this_score )
	
	
func _process(delta: float) -> void:
	if !self._find_leaderboard_in_flight:
		var leaderboard_name = self._pending_leaderboards_to_find.pop_front()
		if leaderboard_name != null:
			if SteamWrapper.is_available():
				var steam = SteamWrapper.get_steam()
				if steam.isSteamRunning():
#					print("STEAM: Finding leaderboard %s" % [ leaderboard_name ] )
					steam.findLeaderboard( leaderboard_name )
					self._find_leaderboard_in_flight = true

	for l in self._leaderboards.values():
		l._process( delta )
