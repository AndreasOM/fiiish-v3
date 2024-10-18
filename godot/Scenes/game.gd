extends Node2D
class_name Game

enum State {
	WAITING_FOR_START,
	SWIMMING,
	DYING,
	DEAD,
	RESPAWNING,
}

signal zone_changed
signal state_changed( state: Game.State )

var _player: Player = Player.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Game - _ready()")
	
	var player = Player.load()
	if player != null:
		_player = player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_player() -> Player:
	return _player

func _on_debug_ui_zoom_changed( value: float ) -> void:
	self.scale.x = value
	self.scale.y = value

func _on_game_manager_zone_changed( name: String ) -> void:
	self.zone_changed.emit( name )


func _on_debug_ui_goto_next_zone() -> void:
	%GameManager.goto_next_zone()


func get_game_manager() -> GameManager:
	return %GameManager


func _on_fish_state_changed(state: Game.State) -> void:
	state_changed.emit( state )
	match state:
		State.DYING:
			_credit_last_swim()
		_:
			pass

func _credit_last_swim():
	var coins = %GameManager.take_coins()
	_player.give_coins(coins)
	
	var distance = %GameManager.take_current_distance_in_meters()
	_player.apply_distance(distance)
	
	_player.save();
