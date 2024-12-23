extends Control

@export var game: Game = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# await get_tree().process_frame
	%SettingsButtonFade.fade_out( 0.0 )
	## %SettingDialog.fade_out( 0.0 )
	## # %SettingsFadeableContainer.fade_out( 0.0 )

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
