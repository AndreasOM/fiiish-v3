extends Control

@export var game: Game = null
@export var musicToggleButton: ToggleButtonContainer = null
@export var soundToggleButton: ToggleButtonContainer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("SettingDialog - _ready()")
	var player = game.get_player()
	if player.isMusicEnabled():
		musicToggleButton.goto_a()
	else:
		musicToggleButton.goto_b()

	if player.isSoundEnabled():
		soundToggleButton.goto_a()
	else:
		soundToggleButton.goto_b()
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_music_toggle_button_container_toggled(state: ToggleButtonContainer.ToggleState) -> void:
	match state:
		ToggleButtonContainer.ToggleState.A:
			print("Music toggle to A")
			game.enableMusic()
			
		ToggleButtonContainer.ToggleState.B:
			print("Music toggle to B")
			game.disableMusic()

func _on_sound_toggle_button_container_toggled(state: ToggleButtonContainer.ToggleState) -> void:
	match state:
		ToggleButtonContainer.ToggleState.A:
			print("Sound toggle to A")
			game.enableSound()
			
		ToggleButtonContainer.ToggleState.B:
			print("Sound toggle to B")
			game.disableSound()
