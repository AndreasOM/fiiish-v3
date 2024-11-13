extends Node2D

var game_manager: GameManager = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var as2d = self.get_node_or_null("%AnimatedSprite2D")
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
