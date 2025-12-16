class_name SteamLeaderboard
extends Object

class Score:
#	var leaderboard_type: LeaderboardTypes.Type
	var value: float

var _name: String = "[NAME]"
var _leaderboard_name: String = "[UNDEFINED]"
var _pending_scores: Array[ Score ] = []
var _leaderboard_handle: int = -1

var _leaderboards: Dictionary[ int, Leaderboard ] = {}

func _init( leaderboard_name: String ) -> void:
#	print("STEAM: Leaderboard._init( %s ) was: %s" % [ leaderboard_name, self._leaderboard_name ] )
	self._leaderboard_name = leaderboard_name
	# :HACK: since only one find request can be in flight we handle this in the SteamLeaderboardManager
	if SteamWrapper.is_available():
		var steam = SteamWrapper.get_steam()
#		if steam.isSteamRunning():
#			steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
#			steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
#			steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)
#			print("STEAM: Finding leaderboard %s" % [ self._leaderboard_name ] )
#			steam.findLeaderboard( self._leaderboard_name )
	
func set_name( name: String ) -> void:
	self._name = name

func handle() -> int:
	return self._leaderboard_handle
	
func _on_leaderboard_find_result(new_handle: int, was_found: int) -> void:
	if !was_found:
		print("STEAM: Leaderboard %s not found" % [ self._leaderboard_name ] )
		return
		
	var api_name: String = SteamWrapper.getLeaderboardName(new_handle)
		
	if api_name == self._leaderboard_name:
		self._leaderboard_handle = new_handle
		print("STEAM: Found leaderboard %s == %s -> %d" % [ self._leaderboard_name, api_name, new_handle ] )
	
func _on_leaderboard_score_uploaded(success: int, this_handle: int, this_score: Dictionary) -> bool:
	if this_handle != self._leaderboard_handle:
		return false

	if success == 0:
		print("[SteamLeaderboard] STEAM: Failed to upload score to leaderboard %s %d -> %s" % [ self._leaderboard_name, this_handle, str(this_score) ] )
		return false
	
	print("[SteamLeaderboard] STEAM: Successfully uploaded score to leaderboard %s %d -> %s" % [ self._leaderboard_name, this_handle, str(this_score) ] )
	
	return true
		
func _on_leaderboard_scores_downloaded(message: String, this_handle: int, these_results: Array, data_request_type: int = 0) -> void:
	if self._leaderboard_handle != this_handle:
		return
#	print( "STEAM: Scores downloaded %s: %s -> %s (%d)" % [ self._leaderboard_name, message, str(these_results), data_request_type ] )
	print( "STEAM: Scores downloaded %s: %s (%d)" % [ self._leaderboard_name, message, data_request_type ] )
	
	var l: Leaderboard = self._leaderboards.get( data_request_type, null )
	if l == null:
		l = Leaderboard.new( self._name, 10 )
		l.set_type( Leaderboard.Type.STEAM )
		self._leaderboards[ data_request_type ] = l

	for e in these_results:
		var steam_id = e.get("steam_id",0)
		# :HACK: until we improve the leaderboard to allow subclassing of participants
		var p = "SteamId=%d" % [ steam_id ]
		l.replace_entry( p, e.get("score", -1))
	
	l.clear_last_added_entry_position()

func send_highscore( value: float ) -> void:
	var score = Score.new()
#	score.leaderboard_type = leaderboard_type
	score.value = value
	self._pending_scores.push_back( score )

func _process(delta: float) -> void:
	if self._leaderboard_handle < 0:
		return
	var s = self._pending_scores.pop_front()
	if s == null:
		return
		
	if SteamWrapper.isSteamRunning():
		var steam = SteamWrapper.get_steam()
		steam.uploadLeaderboardScore( s.value, true, [], self._leaderboard_handle )

func downloadLeaderboardEntries( start_index: int, end_index: int, data_request_type: int ) -> void:
	print("STEAM: SteamLeaderboard.downloadLeaderboardEntries() %s" % [ self._leaderboard_name ] )
	if SteamWrapper.isSteamRunning():
		var steam = SteamWrapper.get_steam()
		steam.downloadLeaderboardEntries( start_index, end_index, data_request_type, self._leaderboard_handle )

func get_leaderboard( data_request_type: int, default: Leaderboard ) -> Leaderboard:
	return self._leaderboards.get( data_request_type, default )
