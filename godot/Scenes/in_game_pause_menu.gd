class_name InGamePauseDialog
extends Dialog

#@export var game: Game = null
@export var fade_time: float = 0.3
@onready var exit_button_fadeable: FadeableContainer = %ExitButtonFadeable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# await get_tree().process_frame
	%SettingsButtonFade.fade_out( 0.0 )
	## %SettingDialog.fade_out( 0.0 )
	## # %SettingsFadeableContainer.fade_out( 0.0 )
	%MainMenuButtonFadeable.fade_out( 0.0 )
	self.exit_button_fadeable.fade_out( 0.0 )
	
	Events.zone_changed.connect( _on_zone_changed )
	Events.game_state_changed.connect( _on_game_state_changed )
	Events.settings_changed.connect( _on_settings_changed )
#	Events.zone_test_enabled.connect( _on_zone_test_enabled )
#	Events.zone_test_disabled.connect( _on_zone_test_disabled )


func open( duration: float ) -> void:
	fade_in( duration )
	
func close( duration: float ) -> void:
	fade_out( duration )

func fade_out( duration: float ) -> void:
	%FadeablePanelContainer.fade_out( duration )

func fade_in( duration: float ) -> void:
	%FadeablePanelContainer.fade_in( duration )

func _on_fadeable_panel_container_on_faded_in() -> void:
	opened()

func _on_fadeable_panel_container_on_faded_out() -> void:
	closed()

func _on_fadeable_panel_container_on_fading_in( _duration: float ) -> void:
	opening()

func _on_fadeable_panel_container_on_fading_out( _duration: float ) -> void:
	closing()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	var state = self._dialog_manager.game.get_state()
	if self._is_main_menu_available( state ):
			if self._dialog_manager.is_dialog_open( DialogIds.Id.MAIN_MENU_DIALOG ):
				if event.is_action_pressed("MainMenu_CloseMainMenu"):
					self._dialog_manager.toggle_dialog( DialogIds.Id.MAIN_MENU_DIALOG, fade_time )
			else:
				if event.is_action_pressed("Swim_OpenMainMenu"):
					self._dialog_manager.toggle_dialog( DialogIds.Id.MAIN_MENU_DIALOG, fade_time )

#	if event.is_action_pressed("toggle_menu"):
#		var state = self._dialog_manager.game.get_state()
#		if self._is_main_menu_available( state ):
#			self._dialog_manager.toggle_dialog( DialogIds.Id.MAIN_MENU_DIALOG, fade_time )

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("Global_TogglePause"):
		# Events.broadcast_global_message("Toggle Pause")
		toggle_pause()
	
func _update_settings_button() -> void:
	var is_paused = self._dialog_manager.game.is_paused()
	var settings_button = %SettingsButtonFade as FadeableContainer
	if settings_button != null:
		if !self._dialog_manager.game.is_in_kids_mode():
			if is_paused:
				settings_button.fade_in( 0.3 )
			else:
				settings_button.fade_out( 0.3 )
		else:
			settings_button.fade_out( 0.3 )
	
func toggle_pause() -> void:
	if self._dialog_manager.game !=	null:
		var is_paused = self._dialog_manager.game.toogle_pause()
		if is_paused:
			%PauseToggleButton.goto_b()
			# Events.broadcast_global_message("Pause -> Paused")
		else:
			%PauseToggleButton.goto_a()
			# Events.broadcast_global_message("Pause -> Resumed")
			self._dialog_manager.close_dialog( DialogIds.Id.SETTING_DIALOG, 0.3 )
		self._update_settings_button()
			
func _on_settings_button_pressed() -> void:
	print("Settings Button pressed")
	## # %SettingsFadeableContainer.toggle_fade( 0.3 )
	## %SettingDialog.toggle_fade( 0.3 )
	self._dialog_manager.toggle_dialog( DialogIds.Id.SETTING_DIALOG, 0.3 )

func _on_pause_toggle_button_toggled( _state: ToggleButtonContainer.ToggleState ) -> void:
	toggle_pause()
	
func _on_zone_changed( _zone ) -> void:
	# print("Zone changed!")
	pass

func _on_game_state_changed( state: Game.State ) -> void:
	# print("State changed -> %d %s" % [ state, Game.state_to_name( state ) ] )
	self._update_main_menu_button( state )

func _on_main_menu_button_pressed() -> void:
	print("Toggle main menu")
	self._dialog_manager.toggle_dialog( DialogIds.Id.MAIN_MENU_DIALOG, fade_time )

func _on_settings_changed() -> void:
	if !self.visible:
		return
	self._update_main_menu_button( self._dialog_manager.game.get_state() )
	self._update_settings_button()

func _is_main_menu_available( state: Game.State ) -> bool:
	var should_be_visible: bool = false
	
	var is_kids_mode_enabled = self._dialog_manager.game.is_in_kids_mode()
	
	if !is_kids_mode_enabled && self._dialog_manager.game.is_main_menu_enabled():
		match state:
			Game.State.PREPARING_FOR_START:
				if self._dialog_manager.game.is_main_menu_enabled():
					should_be_visible = true
			Game.State.WAITING_FOR_START:
				if self._dialog_manager.game.is_main_menu_enabled():
					should_be_visible = true
			# _:
			#	should_be_visible = false
	# else:
	#	should_be_visible = false
	return should_be_visible
	
func _update_main_menu_button( state: Game.State ) -> void:
	if self._dialog_manager == null:
		return
		
	var should_be_visible: bool = self._is_main_menu_available( state )
	

	if should_be_visible:
		%MainMenuButtonFadeable.fade_in( 0.3 )
	else:
		%MainMenuButtonFadeable.fade_out( 0.3 )
		self._dialog_manager.close_dialog( DialogIds.Id.MAIN_MENU_DIALOG, 0.3 )


#func _on_zone_test_enabled( _filename: String ) -> void:
#	self.exit_button_fadeable.fade_in(0.3)

#func _on_zone_test_disabled() -> void:
#	self.exit_button_fadeable.fade_out(0.3)

func _on_exit_button_pressed() -> void:
	self._dialog_manager.game.goto_zone_editor()
