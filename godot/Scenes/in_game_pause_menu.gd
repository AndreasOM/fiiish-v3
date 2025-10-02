class_name InGamePauseDialog
extends Dialog

#@export var game: Game = null
@export var fade_time: float = 0.3
@onready var exit_button_fadeable: FadeableContainer = %ExitButtonFadeable
@onready var pause_toggle_button: ToggleButtonContainer = %PauseToggleButton
@onready var music_toggle_button: FiiishUI_ToggleButton = %MusicToggleButton
@onready var sound_toggle_button: FiiishUI_ToggleButton = %SoundToggleButton
@onready var settings_button: TextureButton = %SettingsButton

var _focus_before_pause: Control = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# await get_tree().process_frame
	%SettingsButtonFade.fade_out( 0.0 )
	## %SettingDialog.fade_out( 0.0 )
	## # %SettingsFadeableContainer.fade_out( 0.0 )
	%MainMenuButtonFadeable.fade_out( 0.0 )
	self.exit_button_fadeable.fade_out( 0.0 )
	
	var game = self._dialog_manager.game
	var settings = game.get_settings()
	if settings.is_music_enabled():
		music_toggle_button.goto_a()
	else:
		music_toggle_button.goto_b()

	if settings.is_sound_enabled():
		sound_toggle_button.goto_a()
	else:
		sound_toggle_button.goto_b()
	
	self.music_toggle_button.fade_out( 0.0 )
	self.sound_toggle_button.fade_out( 0.0 )
	
	Events.zone_changed.connect( _on_zone_changed )
	Events.game_state_changed.connect( _on_game_state_changed )
	Events.settings_changed.connect( _on_settings_changed )
	Events.dialog_opened.connect( _on_dialog_opened )
	Events.dialog_closed.connect( _on_dialog_closed )
	Events.pause_state_changed.connect( _on_pause_state_changed )
#	Events.zone_test_enabled.connect( _on_zone_test_enabled )
#	Events.zone_test_disabled.connect( _on_zone_test_disabled )

func _on_dialog_closed( id: DialogIds.Id ) -> void:
	match id:
		DialogIds.Id.SETTING_DIALOG:
			self.settings_button.grab_focus.call_deferred()
		_:
			pass

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
	
func _update_buttons() -> void:
	var pause_manager = self._dialog_manager.game.get_fiiish_pause_manager()
	var is_paused = pause_manager.is_paused()
	var settings_button = %SettingsButtonFade as FadeableContainer
	if settings_button != null:
		if !self._dialog_manager.game.is_in_kids_mode():
			if is_paused:
				settings_button.fade_in( 0.3 )
				self.music_toggle_button.fade_in( 0.3 )
				self.sound_toggle_button.fade_in( 0.3 )
			else:
				settings_button.fade_out( 0.3 )
				self.music_toggle_button.fade_out( 0.3 )
				self.sound_toggle_button.fade_out( 0.3 )
		else:
			settings_button.fade_out( 0.3 )
			self.music_toggle_button.fade_out( 0.3 )
			self.sound_toggle_button.fade_out( 0.3 )

func toggle_pause() -> void:
	Events.broadcast_player_pause_toggle_requested()

func _on_settings_button_pressed() -> void:
	print("Settings Button pressed")
	## # %SettingsFadeableContainer.toggle_fade( 0.3 )
	## %SettingDialog.toggle_fade( 0.3 )
	self._dialog_manager.toggle_dialog( DialogIds.Id.SETTING_DIALOG, 0.3 )

func _on_pause_toggle_button_toggled( _state: ToggleButtonContainer.ToggleState ) -> void:
	toggle_pause()

func _on_pause_toggle_button_toggle_requested(state: ToggleButtonContainer.ToggleState) -> void:
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
	self._resume_if_paused()

func _resume_if_paused() -> void:
	if self._dialog_manager.game !=	null:
		var is_paused = self._dialog_manager.game.is_paused()
		if is_paused:
			self.toggle_pause()

func _on_settings_changed() -> void:
	if !self.visible:
		return
	self._update_main_menu_button( self._dialog_manager.game.get_state() )
	self._update_buttons()

func _on_pause_state_changed( pause_state: PauseManager.PauseState, reason: PauseManager.PauseReason ) -> void:
	match pause_state:
		PauseManager.PauseState.PAUSED:
			# Only save focus if we haven't already saved it
			if self._focus_before_pause == null:
				self._focus_before_pause = get_viewport().gui_get_focus_owner()
				if self._focus_before_pause != null:
					print("focus was: %s" % self._focus_before_pause.name)
				else:
					print("no focus")

			# Update button to paused state and grab focus
			self.pause_toggle_button.goto_b()
			self.pause_toggle_button.grab_focus.call_deferred()

		PauseManager.PauseState.RUNNING:
			# Update button to running state
			self.pause_toggle_button.goto_a()

			# Close settings dialog when resuming
			self._dialog_manager.close_dialog( DialogIds.Id.SETTING_DIALOG, 0.3 )

			# Restore focus from before pause
			if self._focus_before_pause != null:
				print("focus to: %s" % self._focus_before_pause.name)
				self._focus_before_pause.grab_focus.call_deferred()
				self._focus_before_pause = null
			else:
				print("Focus: release focus")
				get_viewport().gui_release_focus.call_deferred()
		_:
			pass

	# Always update buttons after state change
	self._update_buttons()

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


func _on_pause_toggle_button_focus_entered() -> void:
	pass # Replace with function body.

func _on_dialog_opened( id: DialogIds.Id ) -> void:
	match id:
		DialogIds.Id.MAIN_MENU_DIALOG:
			self._resume_if_paused()
		_:
			pass


func _on_music_toggle_button_toggled(state: FiiishUI_ToggleButton.ToggleState) -> void:
	var game = self._dialog_manager.game
	match state:
		ToggleButtonContainer.ToggleState.A:
			print("Music toggle to A")
			game.enable_music()
			
		ToggleButtonContainer.ToggleState.B:
			print("Music toggle to B")
			game.disable_music()

func _on_sound_toggle_button_toggled(state: FiiishUI_ToggleButton.ToggleState) -> void:
	var game = self._dialog_manager.game
	match state:
		ToggleButtonContainer.ToggleState.A:
			print("Sound toggle to A")
			game.enable_sound()
			
		ToggleButtonContainer.ToggleState.B:
			print("Sound toggle to B")
			game.disable_sound()
