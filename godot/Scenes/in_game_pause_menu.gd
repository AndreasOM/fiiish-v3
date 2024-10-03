extends Control

@export var game: Game = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%SettingsButton.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("TogglePause"):
		toggle_pause()

func toggle_pause():
	if self.game !=	null:
		var tree = self.game.get_tree()
		var was_paused = tree.is_paused()
		var is_paused = !was_paused
		tree.set_pause(is_paused)
		if is_paused:
			%PauseButton.set_a( false )
			%SettingsButton.visible = true
		else:
			%PauseButton.set_a( true )
			%SettingsButton.visible = false 
			
func _on_pause_button_pressed() -> void:
	toggle_pause()
