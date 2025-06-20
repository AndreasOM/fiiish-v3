extends Control

@onready var kids_mode_overlay: MarginContainer = %KidsModeOverlay


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
	self.open_initial_dialogs()
	
	self._handle_launch_parameters()
	
func _handle_launch_parameters() -> void:
	var launch_parameters = self._get_launch_parameters()
	print("Launch Parameters >%s<" % launch_parameters )
	var llp = launch_parameters.to_lower()
	
	if llp.contains("kidsmodedisable"):
		$Game.leave_kids_mode()
	elif llp.contains("kidsmodeenablefreshgame"):
		$Game.enter_kidsmode_with_fresh_game()
	elif llp.contains("kidsmodeenablewithupgrades"):
		$Game.enter_kidsmode_with_upgrades()
	elif llp.contains("kidsmodeenable"):
		%DialogManager.open_dialog( DialogIds.Id.KIDS_MODE_ENABLE_DIALOG, 0.3 )
		
func _get_launch_parameters() -> String:
	if OS.has_feature('web'):
		return self._get_launch_parameters_web()
	else:
		return ""

func _get_launch_parameters_web() -> String:
	var lp = JavaScriptBridge.eval('''
		document.location.search
	''')
	lp = lp.trim_prefix("?")
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


func _on_kids_mode_changed( enabled: bool ) -> void:
	self.kids_mode_overlay.visible = enabled

func _on_settings_changed() -> void:
	if $Game.get_settings().get_developer_dialog_version() > 0:
		%DialogManager.open_dialog( DialogIds.Id.DEVELOPER_DIALOG, 0.3 )
	else:
		%DialogManager.close_dialog( DialogIds.Id.DEVELOPER_DIALOG, 0.3 )
