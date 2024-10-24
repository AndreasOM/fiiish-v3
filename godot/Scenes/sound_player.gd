extends AudioStreamPlayer
class_name SoundPlayer

var _min_seperation: float = 0.0
var _time_since_last_triggered: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_time_since_last_triggered += delta

func load_clip(file: String):
	stream = load(file)

func set_amount( amount: int ):
	max_polyphony = amount

func set_min_seperation( min_seperation: float ):
	_min_seperation = min_seperation

func trigger():
	if _time_since_last_triggered >= _min_seperation:
		play()
		_time_since_last_triggered = 0.0

func fade_out( duration: float ):
	pass
