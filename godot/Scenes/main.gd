extends Control

@onready var kids_mode_overlay: MarginContainer = %KidsModeOverlay
@onready var script_manager: ScriptManager = %ScriptManager

const MarketingScreenshotScript = "res://Features/Scripting/Scripts/marketing_screenshot_script.gd"
const SteamScreenshotScript = "res://Features/Scripting/Scripts/steam_screenshot_script.gd"
const OverlayTestScript = "res://Features/Scripting/Scripts/overlay_test_script.gd"

@onready var achievement_config_manager: AchievementConfigManager = %AchievementConfigManager
@onready var achievement_counter_manager: AchievementCounterManager = %AchievementCounterManager
@onready var achievement_manager: AchievementManager = %AchievementManager
@onready var game: Game = %Game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
			
	if OS.has_feature("demo"):
		enable_developer_console = false

	if enable_developer_console:
		var dcd = %DialogManager.open_dialog(DialogIds.Id.DEVELOPER_CONSOLE_DIALOG, 0.0)
		dcd.fade_out( 0.0 )

	
	
	# var lbd = %DialogManager.open_dialog(DialogIds.Id.LEADERBOARD_DIALOG, 0.0)
	$Game.resume()

	var is_in_kids_mode = $Game.is_in_kids_mode()
	self._on_kids_mode_changed( is_in_kids_mode )
	
	Events.kids_mode_changed.connect( _on_kids_mode_changed )
	
	self._on_settings_changed()
	Events.settings_changed.connect( _on_settings_changed )
	self._on_player_changed( self.game.get_player() )
	Events.player_changed.connect( _on_player_changed )
	self.open_initial_dialogs()
	
	self._handle_launch_parameters()
	
func _on_received_url( url: String ) -> void:
	Events.broadcast_global_message("Received URL: %s" % url )
	var lurl = url.to_lower()	
	self._handle_kids_mode( lurl )

func _on_application_did_become_active( ) -> void:
	Events.broadcast_global_message("Became Active" )


func _handle_launch_parameters() -> void:
	var launch_parameters = self._get_launch_parameters()
	print("Launch Parameters >%s<" % launch_parameters )
	Events.broadcast_log_event( "Launch Parameters: %s" % launch_parameters )
	var llp = launch_parameters.to_lower()
	
	self._handle_kids_mode( llp )
	self._handle_script( launch_parameters )
		
func _handle_script( s: String ) -> void:
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
		$Game.leave_kids_mode()
	elif s.contains("kidsmodeenablefreshgame"):
		$Game.enter_kidsmode_with_fresh_game()
	elif s.contains("kidsmodeenablewithupgrades"):
		$Game.enter_kidsmode_with_upgrades()
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
				for s in args:
					Events.broadcast_global_message( s )

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
	for s in args:
		Events.broadcast_global_message( s )

	var lp = " ".join(args)
		
	print("Launch Parameter >%s<" % lp )

#	EngineDebugger.send_message("omg-launch_control:launch_parameter_used", [lp])
	return lp
		
func open_initial_dialogs() -> void:
	# %DialogManager.open_dialog( DialogIds.Id.MINI_MAP_DIALOG, 0.0 )
	%DialogManager.open_dialog( DialogIds.Id.IN_GAME_PAUSE_DIALOG, 0.0 )
	# %DialogManager.open_dialog( DialogIds.Id.ACHIEVEMENTS_DIALOG, 0.3 )
	var toast_dialog: ToastDialog = %DialogManager.open_dialog( DialogIds.Id.TOAST_DIALOG, 0.0 )
	toast_dialog.add_simple_text_toast( "Started..." )
	Events.broadcast_global_message("Game Started!")
	
#	if OS.has_feature("editor"):
#		%DialogManager.open_dialog( DialogIds.Id.DEVELOPER_DIALOG, 0.0 )
		
	#if $Game.get_settings().get_developer_dialog_version() > 0:
	#	%DialogManager.open_dialog( DialogIds.Id.DEVELOPER_DIALOG, 0.0 )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


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
