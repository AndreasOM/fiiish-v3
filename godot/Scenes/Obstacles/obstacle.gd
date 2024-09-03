extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	var mx = %GameManager.movement_x
	self.transform.origin.x -= mx * delta
	if position.x < -1200.0:
		position.x += 2400.0
