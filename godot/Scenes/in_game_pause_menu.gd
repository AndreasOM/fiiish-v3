extends Control

@export var game: Game = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# await get_tree().process_frame
	%SettingsButtonFade.fade_out( 0.0 )
	%SettingDialog.fade_out( 0.0 )
	# %SettingsFadeableContainer.fade_out( 0.0 )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("TogglePause"):
		toggle_pause()

func toggle_pause():
	if self.game !=	null:
		var tree = self.game.get_tree()
		var was_paused = tree.is_paused()
		var is_paused = !was_paused
		tree.set_pause(is_paused)
		if is_paused:
			%PauseToggleButton.goto_b()
			var settings_button = %SettingsButtonFade as FadeableContainer
			if settings_button:
				settings_button.fade_in( 0.3 )
			else:
				%SettingsButtonFade.visible = true
		else:
			%PauseToggleButton.goto_a()
			%SettingDialog.fade_out( 0.3 )
			# %SettingsFadeableContainer.fade_out( 0.3 )
			var settings_button = %SettingsButtonFade as FadeableContainer
			if settings_button:
				settings_button.fade_out( 0.3 )
			else:
				%SettingsButtonFade.visible = false
			
func _on_settings_button_pressed():
	# %SettingsFadeableContainer.toggle_fade( 0.3 )
	%SettingDialog.toggle_fade( 0.3 )
	print("Settings Button pressed")

func _on_pause_toggle_button_toggled( _state: ToggleButtonContainer.ToggleState ) -> void:
	toggle_pause()
