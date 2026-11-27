class_name Obstacle
extends Entity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var as2d = self.get_node_or_null("%AnimatedSprite2D")
	if as2d != null:
		as2d.play("default")
