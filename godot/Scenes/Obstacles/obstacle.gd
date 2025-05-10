class_name Obstacle
extends Node2D

var game_manager: GameManager = null
@onready var picking_shape: CollisionShape2D = %PickingShape

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var as2d = self.get_node_or_null("%AnimatedSprite2D")
	if as2d != null:
		as2d.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if self.game_manager != null:
		var m = self.game_manager.movement
		self.transform.origin.x -= m.x
		#var mx = self.game_manager.movement_x
		#self.transform.origin.x -= mx * delta

func get_picking_shape() -> CollisionShape2D:
	return self.picking_shape
