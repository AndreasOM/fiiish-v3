class_name SteamLeaderboardManager
extends Node

var _leaderboards: Dictionary[ String, SteamLeaderboard ] = {}

class LeaderboardConfig:
	var steam_name: String
	var name: String
	
	func _init( steam_name: String, name: String ):
		self.steam_name = steam_name
		self.name = name
	
var LEADERBOARD_MAPPINGS: Dictionary[ LeaderboardTypes.Type, LeaderboardConfig ] = {
	LeaderboardTypes.Type.STEAM_SINGLE_RUN_COINS:		LeaderboardConfig.new(
		"dev_max_single_run_coins",
		"Steam Coins"
	),
	LeaderboardTypes.Type.STEAM_SINGLE_RUN_DISTANCE:	LeaderboardConfig.new(
		"dev_max_single_run_distance",
		"Steam Distance"
	),
}

var _pending_leaderboards_to_find: Array[ String ] = []
var _find_leaderboard_in_flight: bool = false

class DownloadEntriesRequest:
	var leaderboard_name: String
	var start_index: int
	var end_index: int
	var data_request_type: int
	
var _pending_leaderboards_to_download: Array[ DownloadEntriesRequest ] = []
var _download_entries_in_flight: DownloadEntriesRequest = null


func _ready() -> void:
	SteamEvents.user_info_required.connect(_on_steam_user_info_required)
	if SteamWrapper.isSteamRunning():
		var steam = SteamWrapper.get_steam()
		steam.persona_state_change.connect( _on_steam_persona_state_change )
		steam.avatar_loaded.connect( _on_steam_avatar_loaded )
		steam.leaderboard_find_result.connect(_on_leaderboard_find_result)
		steam.leaderboard_score_uploaded.connect(_on_leaderboard_score_uploaded)
		steam.leaderboard_scores_downloaded.connect(_on_leaderboard_scores_downloaded)

		for leaderboard_config in LEADERBOARD_MAPPINGS.values():
			var leaderboard_name = leaderboard_config.steam_name
			if !self._leaderboards.has( leaderboard_name ):
				var l = SteamLeaderboard.new( leaderboard_name )
				l.set_name( leaderboard_config.name )
				self._leaderboards[ leaderboard_name ] = l
				self._pending_leaderboards_to_find.push_back( leaderboard_name )
#						print("STEAM: Created new leaderboard for %s" % [ leaderboard_name ] )

func send_highscore(leaderboard_type: LeaderboardTypes.Type, value: float) -> void:
	var leaderboard_config = self.LEADERBOARD_MAPPINGS.get( leaderboard_type, [] )
	var leaderboard_name = leaderboard_config.steam_name
	var l = self._leaderboards.get( leaderboard_name, null )
	if l == null:
		push_warning("Leaderboard does not exist when sending score: %s" % [ leaderboard_name ] )
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
	
	if self._pending_leaderboards_to_find.is_empty():
		self.refresh()
	
func _on_leaderboard_score_uploaded(success: int, this_handle: int, this_score: Dictionary) -> void:
	for l in self._leaderboards.values():
		l._on_leaderboard_score_uploaded( success, this_handle, this_score )
		
	# :HACK: we should be more granular
	self.refresh()
	
func _on_leaderboard_scores_downloaded(message: String, this_handle: int, these_results: Array) -> void:
	var r = self._download_entries_in_flight
	for l in self._leaderboards.values():
		l._on_leaderboard_scores_downloaded( message, this_handle, these_results, r.data_request_type )
		
	self._download_entries_in_flight = null

func refresh() -> void:
	for leaderboard_config in LEADERBOARD_MAPPINGS.values():
		var leaderboard_name = leaderboard_config.steam_name
		# 0 <- LEADERBOARD_DATA_REQUEST_GLOBAL
		self._refresh_leaderboard( leaderboard_name, 0 )
		# :TEST: self._refresh_leaderboard( leaderboard_name, 0 )
		# 1 <- LEADERBOARD_DATA_REQUEST_GLOBAL_AROUND_US
#			self._refresh_leaderboard( leaderboard_name, 1 )
		# 2 <- LEADERBOARD_DATA_REQUEST_FRIENDS
#			self._refresh_leaderboard( leaderboard_name, 2 )
	
func _refresh_leaderboard( name: String, data_request_type: int = 0 ) -> void:
	var l: SteamLeaderboard = self._leaderboards.get( name, null )
	if l == null:
		return
		
	var r = DownloadEntriesRequest.new()
	
	r.leaderboard_name = name
	r.start_index = 0
	r.end_index = 14
	r.data_request_type = data_request_type
	# l.downloadLeaderboardEntries(start_index, end_index, data_request_type)
	self._pending_leaderboards_to_download.push_back( r )
	
func _process(delta: float) -> void:
	for l in self._leaderboards.values():
		l._process( delta )
		
	if self._find_leaderboard_in_flight:
		return
		
	var leaderboard_name = self._pending_leaderboards_to_find.pop_front()
	if leaderboard_name != null:
		if SteamWrapper.isSteamRunning():
			var steam = SteamWrapper.get_steam()
#					print("STEAM: Finding leaderboard %s" % [ leaderboard_name ] )
			steam.findLeaderboard( leaderboard_name )
			self._find_leaderboard_in_flight = true
				
		return

	if self._download_entries_in_flight != null:
		return
		
	if !self._pending_leaderboards_to_download.is_empty():
		var r = self._pending_leaderboards_to_download.pop_front()

		var l = self._leaderboards.get( r.leaderboard_name, null )
		if l == null:
			return
			
		l.downloadLeaderboardEntries(r.start_index, r.end_index, r.data_request_type)
		self._download_entries_in_flight = r
		
		return


func get_leaderboard( type: LeaderboardTypes.Type, default: Leaderboard = null ) -> Leaderboard:
	var config = self.LEADERBOARD_MAPPINGS.get( type, null )
	if config == null:
		return default
		
	var name = config.steam_name
		
	var l: SteamLeaderboard = self._leaderboards.get( name, null )
	if l == null:
		return default
		
	return l.get_leaderboard( 0, default ) # :TODO: handle different types

func _on_steam_persona_state_change( steam_id: int, flags: int ) -> void:
	print("STEAM: _on_steam_persona_state_change %d %d" % [ steam_id, flags] )
	if SteamWrapper.isSteamRunning():
		var n = SteamWrapper.getFriendPersonaName( steam_id )
		#var nf = "%s -> %d" % [ n, flags ]
		SteamEvents.broadcast_user_name_updated( steam_id, n )
	
	
func _on_steam_avatar_loaded( steam_id: int, width: int, data: PackedByteArray ):
	# print( "STEAM: avatar loaded %d %s" % [ width, str(data) ] )
	var avatar_image: Image = Image.create_from_data(width, width, false, Image.FORMAT_RGBA8, data)

#	if width > 32:
#		avatar_image.resize(32, 32, Image.INTERPOLATE_LANCZOS)
	var avatar_texture: ImageTexture = ImageTexture.create_from_image(avatar_image)
	
	SteamEvents.broadcast_user_texture_updated( steam_id, avatar_texture )
	
func _on_steam_user_info_required( steam_id: int ) -> void:
	if SteamWrapper.isSteamRunning():
		var steam = SteamWrapper.get_steam()
		var n = SteamWrapper.getFriendPersonaName( steam_id )
		SteamEvents.broadcast_user_name_updated( steam_id, n )

		steam.getPlayerAvatar( 1, steam_id )
		# steam.getPlayerAvatar( 3, steam_id )
		# steam.getPlayerAvatar( 2, steam_id )
			
#	SteamEvents.broadcast_user_name_updated( steam_id, "???" )
	
