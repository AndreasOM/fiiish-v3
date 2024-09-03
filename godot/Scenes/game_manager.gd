extends Node
class_name GameManager

@export var movement_x: float = 240.0:
	get:
		if self._paused:
			return 0.0
		else:
			return movement_x

var _paused: bool = true

var _rock_b = preload("res://Scenes/Obstacles/rock_b.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func pause():
	self._paused = true

func resume():
	self._paused = false

func spawn_zone():
	var xs = [ 1200.0, 1500.0, 1800.0 ]
	var y = 410.0
	for x in xs:
		var o = _rock_b.instantiate()
		o.game_manager = self
		o.position = Vector2( x, y )
		%Obstacles.add_child(o)

func cleanup():
	for o in %Obstacles.get_children():
		%Obstacles.remove_child(o)
		o.queue_free()
