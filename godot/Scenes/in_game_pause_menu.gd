extends Control

@export var game: Game = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# await get_tree().process_frame
	%SettingsButtonFade.fade_out( 0.0 )
	## %SettingDialog.fade_out( 0.0 )
	## # %SettingsFadeableContainer.fade_out( 0.0 )
	%MainMenuButtonFadeable.fade_out( 0.0 )
	
	Events.zone_changed.connect( _on_zone_changed )
	Events.state_changed.connect( _on_state_changed )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
#	if Input.is_action_just_pressed("TogglePause"):
#		toggle_pause()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("TogglePause"):
		toggle_pause()
	
func toggle_pause():
	if self.game !=	null:
		var is_paused = self.game.toogle_pause()
		if is_paused:
			%PauseToggleButton.goto_b()
			var settings_button = %SettingsButtonFade as FadeableContainer
			if settings_button:
				settings_button.fade_in( 0.3 )
			else:
				%SettingsButtonFade.visible = true
		else:
			%PauseToggleButton.goto_a()
			## :TODO:
			## %SettingDialog.fade_out( 0.3 )
			## # %SettingsFadeableContainer.fade_out( 0.3 )
			%DialogManager.close_dialog( DialogIds.Id.SETTING_DIALOG, 0.3 )
			var settings_button = %SettingsButtonFade as FadeableContainer
			if settings_button:
				settings_button.fade_out( 0.3 )
			else:
				%SettingsButtonFade.visible = false
			
func _on_settings_button_pressed():
	print("Settings Button pressed")
	## # %SettingsFadeableContainer.toggle_fade( 0.3 )
	## %SettingDialog.toggle_fade( 0.3 )
	%DialogManager.toggle_dialog( DialogIds.Id.SETTING_DIALOG, 0.3 )

func _on_pause_toggle_button_toggled( _state: ToggleButtonContainer.ToggleState ) -> void:
	toggle_pause()
	
func _on_zone_changed( zone ):
	# print("Zone changed!")
	pass

func _on_state_changed( state: Game.State ):
	# print("State changed -> %d %s" % [ state, Game.state_to_name( state ) ] )
	match state:
		Game.State.RESPAWNING:
			%MainMenuButtonFadeable.fade_in( 0.3 )
		Game.State.WAITING_FOR_START:
			%MainMenuButtonFadeable.fade_in( 0.3 )
		_:
			%MainMenuButtonFadeable.fade_out( 0.3 )
			%DialogManager.close_dialog( DialogIds.Id.MAIN_MENU_DIALOG, 0.3 )
			pass


func _on_main_menu_button_pressed() -> void:
	print("Toggle main menu")
	%DialogManager.toggle_dialog( DialogIds.Id.MAIN_MENU_DIALOG, 0.3 )
