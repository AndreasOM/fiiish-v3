extends Node2D

const PickupEffect = preload("res://Scripts/pickup_effect.gd").PickupEffect

var game_manager: GameManager = null

@export var _coin_value: int = 0
@export var _effect: PickupEffect = PickupEffect.NONE

func is_alive() -> bool:
	return true

func collect():
	pass

func effect() -> PickupEffect:
	return _effect

func coin_value() -> int:
	return _coin_value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var as2d = self.get_node("%AnimatedSprite2D")
	if as2d != null:
		as2d.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if self.game_manager != null:
		var mx = self.game_manager.movement_x
		self.transform.origin.x -= mx * delta
		if position.x < self.game_manager.left_boundary:
			var wo = self.game_manager.left_boundary_wrap_offset
			if wo > 0:
				position.x += wo
			else:
				queue_free()
