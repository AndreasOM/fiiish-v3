class_name SteamLeaderboard
extends Object

class Score:
#	var leaderboard_type: LeaderboardTypes.Type
	var value: float

var _leaderboard_name: String = "[UNDEFINED]"
var _pending_scores: Array[ Score ] = []
var _leaderboard_handle: int = -1

func _init( leaderboard_name: String ) -> void:
#	print("STEAM: Leaderboard._init( %s ) was: %s" % [ leaderboard_name, self._leaderboard_name ] )
	self._leaderboard_name = leaderboard_name
	# :HACK: since only one find request can be in flight we handle this in the SteamLeaderboardManager
#	if SteamWrapper.is_available():
#		var steam = SteamWrapper.get_steam()
#		if steam.isSteamRunning():
#			steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
#			steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
#			print("STEAM: Finding leaderboard %s" % [ self._leaderboard_name ] )
#			steam.findLeaderboard( self._leaderboard_name )
	
func _on_leaderboard_find_result(new_handle: int, was_found: int) -> void:
	if !was_found:
		print("STEAM: Leaderboard %s not found" % [ self._leaderboard_name ] )
		return
		
	var steam = SteamWrapper.get_steam()
	var api_name: String = steam.getLeaderboardName(new_handle)
		
	if api_name == self._leaderboard_name:
		self._leaderboard_handle = new_handle
		print("STEAM: Found leaderboard %s == %s -> %d" % [ self._leaderboard_name, api_name, new_handle ] )
	
func _on_leaderboard_score_uploaded(success: int, this_handle: int, this_score: Dictionary) -> void:
	if this_handle != self._leaderboard_handle:
		return

	if success == 0:
		print("STEAM: Failed to upload score to leaderboard %s %d -> %s" % [ self._leaderboard_name, this_handle, str(this_score) ] )
		return
	
	var s = str(this_score)
	print("STEAM: Successfully uploaded score to leaderboard %s %d -> %s" % [ self._leaderboard_name, this_handle, s ] )
		
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
		
	if SteamWrapper.is_available():
		var steam = SteamWrapper.get_steam()
		if steam.isSteamRunning():
			steam.uploadLeaderboardScore( s.value, true, [], self._leaderboard_handle )
