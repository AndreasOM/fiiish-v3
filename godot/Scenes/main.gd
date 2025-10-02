extends Control

@onready var kids_mode_overlay: MarginContainer = %KidsModeOverlay
@onready var script_manager: ScriptManager = %ScriptManager

const MarketingScreenshotScript = "res://Features/Scripting/Scripts/marketing_screenshot_script.gd"
const MarketingTrailerScript = "res://Features/Scripting/Scripts/marketing_trailer_script.gd"
const SteamScreenshotScript = "res://Features/Scripting/Scripts/steam_screenshot_script.gd"
const OverlayTestScript = "res://Features/Scripting/Scripts/overlay_test_script.gd"

@onready var achievement_config_manager: AchievementConfigManager = %AchievementConfigManager
@onready var achievement_counter_manager: AchievementCounterManager = %AchievementCounterManager
@onready var achievement_manager: AchievementManager = %AchievementManager
@onready var game: Game = %Game
@onready var dialog_manager: DialogManager = %DialogManager

var _was_paused_before_focus_was_lost: bool = false

var _steam_input_handles: Dictionary = {}
var _last_action_set: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print_rich("[color=green]main _ready() ->[/color]")
	
	#get_window().size = Vector2i( 1920*2*0.75, 1080*2*0.75 )
	#get_window().position = Vector2i( 1920*2, 0 )
	if !OS.has_feature("standalone"):
		get_window().borderless = false
		pass
		
	#var s = 0.5
	
	# DisplayServer.window_set_size( s*Vector2( 1920.0, 1080.0 ) )
	#get_window().set_size( Vector2i( s*Vector2( 1920.0, 1080.0 ) ) )
	# get_tree().get_root().size = s*Vector2( 1920.0, 1080.0 )
	var enable_developer_console = true
	match OS.get_name():
		"Windows":
			print("Welcome to Windows!")
		"macOS":
			print("Welcome to macOS!")
		"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
			print("Welcome to Linux/BSD!")
		"Android":
			print("Welcome to Android!")
		"iOS":
			print("Welcome to iOS!")
			enable_developer_console = false
			if Engine.has_singleton("OMGLifecyclePlugin_iOS"):
				var singleton = Engine.get_singleton("OMGLifecyclePlugin_iOS")
				singleton.received_url.connect(_on_received_url)
				singleton.application_did_become_active.connect(_on_application_did_become_active)
		"Web":
			print("Welcome to the Web!")
			
	if FeatureTags.has_feature("demo"):
		enable_developer_console = false

	if enable_developer_console:
		var dcd = %DialogManager.open_dialog(DialogIds.Id.DEVELOPER_CONSOLE_DIALOG, 0.0)
		dcd.fade_out( 0.0 )

	
	Events.game_state_changed.connect( _on_game_state_changed )
	# Events.game_paused_v1.connect( _on_game_paused )  # OLD SYSTEM - DISABLED
	Events.pause_state_changed.connect( _on_pause_state_changed )
	Events.player_pause_toggle_requested.connect( _on_player_pause_toggle_requested )
	# var lbd = %DialogManager.open_dialog(DialogIds.Id.LEADERBOARD_DIALOG, 0.0)
	# $Game.resume()  # OLD SYSTEM - new system auto-starts in RUNNING state

	var is_in_kids_mode = $Game.is_in_kids_mode()
	self._on_kids_mode_changed( is_in_kids_mode )
	
	Events.kids_mode_changed.connect( _on_kids_mode_changed )
	
	self._on_settings_changed()
	Events.settings_changed.connect( _on_settings_changed )
	self._on_player_changed( self.game.get_player() )
	Events.player_changed.connect( _on_player_changed )
	self.open_initial_dialogs()
	
	self._handle_launch_parameters()

#	if FeatureTags.has_feature("steam"):
#		Events.broadcast_global_message("STEAM!")

	# OLD FOCUS CONNECTIONS DISABLED - FiiishPauseManager handles window focus now
	# get_window().focus_exited.connect( _on_window_focus_exited )
	# get_window().focus_entered.connect( _on_window_focus_entered )
	
	if SteamWrapper.is_available():
		print_rich("[color=green]---=== Setting up Steam Integration ===---[/color]")
		var ir = SteamWrapper.get_initial_response()
		var s = "Steam: %s" % ir
		# Events.broadcast_global_message( s )
		Events.broadcast_developer_message( DeveloperMessageDebug.new( s ) )
		var steam = SteamWrapper.get_steam()
		if steam.isSteamRunning():
		
			steam.input_device_connected.connect( _on_input_device_connected )
			steam.input_device_disconnected.connect( _on_input_device_disconnected )
			steam.inputInit()
			steam.enableDeviceCallbacks()

			# var steam_controller_input = SteamWrapper.get_steam_controller_input()

			#steam_controller_input.init()
		#		var da = DirAccess.open("")
		#		var cwd = da.get_current_dir()
		#		print( cwd )

		#		var files = ResourceLoader.list_directory( "." )
		#		for file in files:
		#			print(file)
			
			
			
			
			#var exe_path = OS.get_executable_path()
			#print("exe_path %s" % exe_path )
			var manifest_file = self._get_global_steam_manifest_path()
			#var manifest_file = ProjectSettings.globalize_path( "user://steam_manifest.vdf")
			#var manifest_file = ProjectSettings.globalize_path( "res://steam_manifest.vdf")
		#		var manifest_file = "/Users/anti/data/work/anti666tv/fiiish-v3/steam/steam_manifest.vdf"
			#var manifest_file = "/Users/anti/data/work/anti666tv/fiiish-v3/godot/steam_manifest.vdf"
			#var manifest_file = "steam_manifest.vdf"
			#var manifest_file = "res://../steam/steam_manifest.vdf"
			#var manifest_file = "res://steam_manifest.vdf"
			#var manifest_file = "steam_manifest.vdf"
			#var manifest_file = "BROKEN"
			#var manifest_file = "/Users/anti/Library/Application%20Support/Godot/app_userdata/fiiish-v3/steam_manifest.vdf"
			print("manifest_file %s" % manifest_file )
			if !FileAccess.file_exists( manifest_file ):
				push_warning("Action manifest file not found %s" % manifest_file )
				Events.broadcast_global_message( "Action manifest file not found %s" % manifest_file )
			else:
				if true:
					if !steam.setInputActionManifestFilePath( manifest_file):
						#get_tree().quit(0)
						#OS.crash("Failed loading steam action manifest")
						push_warning("Failed loading steam action manifest")
						Events.broadcast_global_message( "Failed loading action manifest %s" % manifest_file )
						print("manifest_file FAILURE")
					else:
						print("manifest_file SUCCESS")
						self._update_action_set( Game.State.INITIAL )
			steam.overlay_toggled.connect(_on_steam_overlay_toggled)

	Events.dialog_opened.connect( _on_dialog_opened )
	Events.dialog_closed.connect( _on_dialog_closed )
	get_viewport().connect("gui_focus_changed", _on_focus_changed)
	print_rich("[color=green]<- main _ready() - DONE[/color]")
	
	for f in range(10):
		await get_tree().process_frame
		print_rich("[color=green]main _ready() - process_frame %d[/color]" % f)

func _on_focus_changed(control:Control) -> void:
	if control != null:
		print( "Focus: changed to %s" % control.name )

func _copy_res_to_user( res: String, user: String ) -> bool:
	var src = FileAccess.open( res, FileAccess.READ )
	if src == null:
		push_warning("Copy src >%s< not readable!" % src )
		return false

	var dst = FileAccess.open( user, FileAccess.WRITE )
	if dst == null:
		push_warning("Copy dst >%s< not writable!" % dst )
		return false
	
	var data = src.get_as_text()
	dst.store_string( data )
	
	return true

func _get_global_steam_manifest_path() -> String:
	
	if OS.has_feature("editor"):
		return ProjectSettings.globalize_path( "res://steam_manifest.vdf" )
	else:
		var path = OS.get_executable_path().get_base_dir()
		match OS.get_name():
			"macOS":
				path = path.path_join("../Resources/").simplify_path()
			_:
				pass
		path = path.path_join("steam_manifest.vdf")

		# :TODO: check on windows & macos -> ../Resources/
		return path

#		return "/home/deck/.local/share/Steam/steamapps/common/Fiiish! Classic Demo/steam_manifest.vdf"
		
#		self._copy_res_to_user( "res://steam_manifest.vdf", "user://steam_manifest.vdf")
#		self._copy_res_to_user( "res://config_2960490_controller_xboxone.vdf", "user://config_2960490_controller_xboxone.vdf")
		
#		return ProjectSettings.globalize_path( "user://steam_manifest.vdf")
	

func _on_input_device_connected( input_handle: int ) -> void:
	# Events.broadcast_global_message( "Input device connected [%d]" % input_handle )
	self._steam_input_handles[ input_handle ] = true

func _on_input_device_disconnected( input_handle: int ) -> void:
	# Events.broadcast_global_message( "Input device disconnected [%d]" % input_handle )
	self._steam_input_handles[ input_handle ] = false
	
func _update_action_set( state: Game.State ) -> void:
	const MENU_CONTROLS: String = "MenuControls"
	const SWIM_CONTROLS: String = "SwimControls"
	if SteamWrapper.is_available():
		var steam = SteamWrapper.get_steam()
		if !steam.isSteamRunning() && false:
			return
		var action_set_name = MENU_CONTROLS
		var reason = "default"
		match state:
			Game.State.WAITING_FOR_START:
				action_set_name = SWIM_CONTROLS
			Game.State.PREPARING_FOR_START:
				action_set_name = SWIM_CONTROLS
			Game.State.SWIMMING:
				action_set_name = SWIM_CONTROLS

		if self.dialog_manager.game.is_paused():
			action_set_name = MENU_CONTROLS
			reason = "paused"
		elif self.dialog_manager.is_dialog_open( DialogIds.Id.MAIN_MENU_DIALOG ):
			action_set_name = MENU_CONTROLS
			reason = "main menu"
		elif self.dialog_manager.is_dialog_open( DialogIds.Id.LEADERBOARD_DIALOG ):
			action_set_name = MENU_CONTROLS
			reason = "leaderboard"
		elif self.dialog_manager.is_dialog_open( DialogIds.Id.ACHIEVEMENTS_DIALOG ):
			action_set_name = MENU_CONTROLS
			reason = "achievements"
		elif self.dialog_manager.is_dialog_open( DialogIds.Id.CREDITS_DIALOG ):
			action_set_name = MENU_CONTROLS
			reason = "credits"
		elif self.dialog_manager.is_dialog_open( DialogIds.Id.ABOUT_DEMO_DIALOG ):
			action_set_name = MENU_CONTROLS
			reason = "about demo"
		elif self.dialog_manager.is_dialog_open( DialogIds.Id.KIDS_MODE_ENABLE_DIALOG ):
			action_set_name = MENU_CONTROLS
			reason = "kids mode"
				
		if self._last_action_set != action_set_name:
			self._last_action_set = action_set_name
			#var action_set_handle = steam.getActionSetHandle( "Set_Swim" )
			var action_set_handle = steam.getActionSetHandle( action_set_name )
			# print("action_set_handle %d <- %s" % [ action_set_handle, action_set_name ])
			#if action_set_handle != 0:
			# Events.broadcast_global_message("ash %d <- %s [%s]" % [ action_set_handle, action_set_name, reason ])
			Events.broadcast_developer_message(
				DeveloperMessageDebug.new(
					"ash %d <- %s [%s]" % [ action_set_handle, action_set_name, reason ]
				)
			)
			for k in self._steam_input_handles.keys():
				var h = self._steam_input_handles.get( k, false )
				if h == false:
					continue
				steam.activateActionSet( k, action_set_handle )
	else:
		print("Update Action Set without Steam -> do nothing")
	
func _on_game_state_changed( state: Game.State ) -> void:
	self._update_action_set( state )
	_fix_startup_pause_state( state )

func _fix_startup_pause_state( state: Game.State ) -> void:
	match state:
		Game.State.PREPARING_FOR_START, Game.State.WAITING_FOR_START:
			print("NEW PAUSE SYSTEM: _fix_startup_pause_state triggered for %s" % game.state_to_name(state))
			var pause_manager = %FiiishPauseManager.get_pause_manager()
			print("NEW PAUSE SYSTEM: requesting player resume to fix startup artifacts")
			pause_manager.request_player_resume()
		_:
			print("NEW PAUSE SYSTEM: _fix_startup_pause_state called with state: %s" % game.state_to_name(state))

func _on_pause_state_changed( pause_state: PauseManager.PauseState, reason: PauseManager.PauseReason ) -> void:
	var state = self.game.get_state()
	self._update_action_set( state )

func _on_player_pause_toggle_requested() -> void:
	%FiiishPauseManager.toggle_player_pause()

func _on_dialog_opened( id: DialogIds.Id ) -> void:
	# if id == DialogIds.Id.MAIN_MENU_DIALOG:
		var state = self.game.get_state()
		self._update_action_set( state )

func _on_dialog_closed( id: DialogIds.Id ) -> void:
	# if id == DialogIds.Id.MAIN_MENU_DIALOG:
		var state = self.game.get_state()
		self._update_action_set( state )

func _on_steam_overlay_toggled( active: bool, _user_initiated: bool, _app_id: int ) -> void:
	# Steam overlay does NOT trigger window focus events automatically, so we handle manually
	if active:
		# Steam overlay opened - pause via new system
		%FiiishPauseManager.get_pause_manager().notify_focus_lost()
		Events.broadcast_global_message( "Overlay Toggled ON")
	else:
		# Steam overlay closed - resume via new system
		%FiiishPauseManager.get_pause_manager().notify_focus_gained()
		Events.broadcast_global_message( "Overlay Toggled OFF")
	
# OLD FOCUS HANDLER - DISABLED - FiiishPauseManager handles focus events now
# func _on_window_focus_entered() -> void:
#	#self.resume()
#	self.process_mode = Node.PROCESS_MODE_INHERIT
#	# get_tree().paused = false
#	if !self._was_paused_before_focus_was_lost:
#		self.game.resume()
	
# OLD FOCUS HANDLER - DISABLED - FiiishPauseManager handles focus events now
# func _on_window_focus_exited() -> void:
#	const PAUSE_ON_FOCUS_LOSS: bool = false	# :TODO: could be a setting
#	if SteamWrapper.is_available():
#		var steam = SteamWrapper.get_steam()
#		#if PAUSE_ON_FOCUS_LOSS || steam.isSteamRunningOnSteamDeck():
#		if PAUSE_ON_FOCUS_LOSS || steam.isSteamRunning():
#			self.process_mode = Node.PROCESS_MODE_DISABLED
#			if self.game.is_paused():
#				self._was_paused_before_focus_was_lost = true
#			else:
#				self._was_paused_before_focus_was_lost = false
#				self.game.pause()

	
func _on_received_url( url: String ) -> void:
#	Events.broadcast_global_message("Received URL: %s" % url )
	var lurl = url.to_lower()	
	self._handle_kids_mode( lurl )

func _on_application_did_become_active( ) -> void:
#	Events.broadcast_global_message("Became Active" )
	pass


func _handle_launch_parameters() -> void:
	var launch_parameters = self._get_launch_parameters()
	print("Launch Parameters >%s<" % launch_parameters )
	Events.broadcast_log_event( "Launch Parameters: %s" % launch_parameters )
	var llp = launch_parameters.to_lower()
	
	self._handle_kids_mode( llp )
##	self._handle_demo( launch_parameters )
	self._handle_script( launch_parameters )
		
##func _handle_demo( s: String ) -> void:
##	if !s.contains("--demo"):
##		return
##		
##	FeatureTags.add_extra_feature( "demo" )
	
func _handle_script( s: String ) -> void:
	if s.begins_with("uid://"):
		var first_space = s.find(" ")
		if first_space > 0:
			s = s.substr( first_space+1 )
		else:
			s = ""
		#print("Removed uid:// -> >%s< (%d)" % [ s, first_space ])
		
	if !s.begins_with("--script:"):
		return
	s = s.trim_prefix("--script:")
	if !s.begins_with("\""):
		return
	if !s.ends_with("\""):
		return
	s = s.trim_prefix("\"")
	s = s.trim_suffix("\"")
	var script = null
	match s:
		"MarketingScreenshots":
			script = load(MarketingScreenshotScript)
		"MarketingTrailer":
			script = load(MarketingTrailerScript)
		"SteamScreenshots":
			script = load(SteamScreenshotScript)
		"OverlayTest":
			script = load(OverlayTestScript)
		_:
			return
			
	var script_node: Node = Node.new()
	script_node.name = "Script Node"
	script_node.set_script( script )
	self.add_child( script_node )
	
	
	if script_node.has_method("run"):
		print("Starting script >%s<" % s)
		await script_node.run( script_manager )
	
func _handle_kids_mode( s: String ) -> void:
	if s.contains("kidsmodedisable"):
		self.game.leave_kids_mode()
	elif s.contains("kidsmodeenablefreshgame"):
		self.game.enter_kidsmode_with_fresh_game()
	elif s.contains("kidsmodeenablewithupgrades"):
		self.game.enter_kidsmode_with_upgrades()
	elif s.contains("kidsmodeenable"):
		%DialogManager.open_dialog( DialogIds.Id.KIDS_MODE_ENABLE_DIALOG, 0.3 )
	
func _get_launch_parameters() -> String:
	if OS.has_feature("editor"):
		return self._get_launch_parameters_editor()
	else:
		match OS.get_name():
			"Windows":
				return ""
#			"macOS":
# just use standard cmd line args
#				return ""
			"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
				return ""
			"Android":
				return ""
			"iOS":
				return self._get_launch_parameters_ios()
			"Web":
				return self._get_launch_parameters_web()
			_:
				var args = OS.get_cmdline_args()
#				for s in args:
#					Events.broadcast_global_message( s )

				var lp = " ".join(args)
				return lp
				
func _get_launch_parameters_ios() -> String:
	if Engine.has_singleton("OMGLifecyclePlugin_iOS"):
		var singleton = Engine.get_singleton("OMGLifecyclePlugin_iOS")
		print(singleton.foo())
		var lp = singleton.get_last_url_string()
		return lp
	return ""

func _get_launch_parameters_web() -> String:
	var lp = JavaScriptBridge.eval('''
		document.location.search
	''')
	lp = lp.trim_prefix("?")
	return lp
	
func _get_launch_parameters_editor() -> String:
	
	if !EngineDebugger.is_active():
		push_warning("No EngineDebugger active when running from editor")
		return ""
		
	var args = OS.get_cmdline_args()
	if args.size() > 0:
		var scene = args[ 0 ]
		print("Startup Scene: ", scene)
		args.remove_at( 0 )
#	for s in args:
#		Events.broadcast_global_message( s )

	var lp = " ".join(args)
		
	print("Launch Parameter >%s<" % lp )

#	EngineDebugger.send_message("omg-launch_control:launch_parameter_used", [lp])
	return lp
		
func open_initial_dialogs() -> void:
	# %DialogManager.open_dialog( DialogIds.Id.MINI_MAP_DIALOG, 0.0 )
	%DialogManager.open_dialog( DialogIds.Id.IN_GAME_PAUSE_DIALOG, 0.0 )
	# %DialogManager.open_dialog( DialogIds.Id.ACHIEVEMENTS_DIALOG, 0.3 )
	var toast_dialog: ToastDialog = %DialogManager.open_dialog( DialogIds.Id.TOAST_DIALOG, 0.0 )
#	toast_dialog.add_simple_text_toast( "Started..." )
#	Events.broadcast_global_message("Game Started!")
	
#	if OS.has_feature("editor"):
#		%DialogManager.open_dialog( DialogIds.Id.DEVELOPER_DIALOG, 0.0 )
		
	#if $Game.get_settings().get_developer_dialog_version() > 0:
	#	%DialogManager.open_dialog( DialogIds.Id.DEVELOPER_DIALOG, 0.0 )

#	if DeveloperOverlayDialog.is_developer():
#		%DialogManager.open_dialog( DialogIds.Id.DEVELOPER_OVERLAY_DIALOG, 0.0 )
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
#	print_rich("[color=yellow]main - _process ->[/color]")
	
	var pa1 = PerformanceArea.new( "MainProcess" )
	#PerformanceMonitor.draw( $UI/Performance/Performance2 )
	var state = self.game.get_state()
	self._update_action_set( state )
	PerformanceMonitor.next_frame()

func _on_player_changed( player: Player ) -> void:
	if self.achievement_manager != null:
		self.achievement_manager.reset_achievements()
		for a in player.completed_achievements():
			self.achievement_manager.mark_achievement_completed( a )
		for a in player.collected_achievements():
			self.achievement_manager.mark_achievement_collected( a )
	if self.achievement_counter_manager != null:
		self.achievement_counter_manager.reset_counters()

	# update counters for play achievement
	var date = Time.get_date_dict_from_system( true )
	if date["year"] == 2025:
# not possible anymore
#		if date["month"] == 5:
#			
#			self.achievement_counter_manager.set_counter( AchievementCounterIds.Id.PLAYED_BEFORE_JUNE_2025, 1 )
		if date["month"] < 9:
			self.achievement_counter_manager.set_counter( AchievementCounterIds.Id.PLAYED_BEFORE_SEPTEMBER_2025, 1 )
		if date["month"] < 10:
			self.achievement_counter_manager.set_counter( AchievementCounterIds.Id.PLAYED_DURING_STEAM_NEXT_FEST_2025_10, 1 )
		elif date["month"] == 10:
			if date["day"] <= 20:
				self.achievement_counter_manager.set_counter( AchievementCounterIds.Id.PLAYED_DURING_STEAM_NEXT_FEST_2025_10, 1 )

	if FeatureTags.has_feature("demo"):
		self.achievement_counter_manager.set_counter( AchievementCounterIds.Id.IS_DEMO, 1 )
		
	if FeatureTags.has_feature("steam"):
		self.achievement_counter_manager.set_counter( AchievementCounterIds.Id.IS_STEAM, 1 )
		
	var day_streak_length = player.day_streak_length()
	self.achievement_counter_manager.set_counter(AchievementCounterIds.Id.DAY_STREAK, day_streak_length )
	print("Day Streak Length %d" % day_streak_length)


func _on_kids_mode_changed( enabled: bool ) -> void:
	self.kids_mode_overlay.visible = enabled

func _on_settings_changed() -> void:
	if $Game.get_settings().get_developer_dialog_version() > 0:
		%DialogManager.open_dialog( DialogIds.Id.DEVELOPER_DIALOG, 0.3 )
	else:
		%DialogManager.close_dialog( DialogIds.Id.DEVELOPER_DIALOG, 0.3 )
		
	var game: Game = $Game as Game
	if game == null:
		return
	var settings := game.get_settings()
	if settings == null:
		return
	if settings.dev_is_developer_overlay_enabled():
		if DeveloperOverlayDialog.is_developer():
			%DialogManager.open_dialog( DialogIds.Id.DEVELOPER_OVERLAY_DIALOG, 0.0 )

	
	


func _on_steam_input_controller_disconnected() -> void:
	# NEW PAUSE SYSTEM: Controller disconnect triggers pause
	%FiiishPauseManager.get_pause_manager().notify_controller_disconnected()
