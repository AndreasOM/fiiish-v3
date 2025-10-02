class_name FiiishPauseManager extends Node

@onready var _pause_manager: PauseManager = $PauseManager
@export var _game: Game
@export var _steam_input: SteamInput

func _ready():
	# Listen to signals coming UP from PauseManager
	_pause_manager.pause_state_changed.connect(_on_pause_state_changed)

	# Connect external pause triggers directly with debug wrappers
	get_window().focus_exited.connect(_on_focus_lost)
	get_window().focus_entered.connect(_on_focus_gained)

	# Connect controller events via export property
	if _steam_input != null:
		_steam_input.controller_disconnected.connect(_pause_manager.notify_controller_disconnected)

# Input handling moved to InGamePauseMenu where it belongs
# func _unhandled_input(event: InputEvent):
#	if event.is_action_pressed("Global_TogglePause"):
#		_pause_manager.toggle_player_pause()

# React to signals coming UP from PauseManager
func _on_pause_state_changed(state: PauseManager.PauseState, reason: PauseManager.PauseReason):
	var message = "NEW PAUSE SYSTEM: %s (%s)" % [PauseManager.state_to_string(state), PauseManager.reason_to_string(reason)]
	print(message)
	Events.broadcast_developer_message(DeveloperMessageDebug.new(message))

	# NOW ACTUALLY CONTROL GAME PAUSE STATE
	match state:
		PauseManager.PauseState.PAUSED:
			_game.get_tree().set_pause(true)
			print("NEW PAUSE SYSTEM: tree.set_pause(true)")
		PauseManager.PauseState.RUNNING:
			_game.get_tree().set_pause(false)
			print("NEW PAUSE SYSTEM: tree.set_pause(false)")
		_:
			pass

	# Broadcast new pause state changed event
	Events.broadcast_pause_state_changed(state, reason)

# Debug wrapper for focus events
func _on_focus_lost():
	print("NEW PAUSE SYSTEM: focus_exited triggered")
	_pause_manager.notify_focus_lost()

func _on_focus_gained():
	print("NEW PAUSE SYSTEM: focus_entered triggered")
	_pause_manager.notify_focus_gained()

# Public API
func toggle_player_pause() -> void:
	_pause_manager.toggle_player_pause()

func is_paused() -> bool:
	return _pause_manager.is_paused()

# Debug access
func get_pause_manager() -> PauseManager:
	return _pause_manager
