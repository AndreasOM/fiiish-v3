extends AudioStreamPlayer
class_name SoundPlayer

var _min_seperation: float = 0.0
var _time_since_last_triggered: float = 0.0
var _loop: bool = false
var _fade: float = 0.0
var _fadeSpeed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_time_since_last_triggered += delta
	if _fadeSpeed != 0.0:
		_fade += _fadeSpeed*delta
		if _fade >= 1.0:
			_fade = 1.0
			_fadeSpeed = 0.0
		elif _fade <= 0.0:
			_fade = 0.0
			stop()
			_fadeSpeed = 0.0
		volume_db = linear_to_db(_fade)

func load_clip(file: String):
	stream = load(file)

func set_amount( amount: int ):
	max_polyphony = amount

func set_min_seperation( min_seperation: float ):
	_min_seperation = min_seperation

func set_loop( loop: bool ):
	_loop = loop

func trigger():
	if _time_since_last_triggered >= _min_seperation:
		play()
		fade_in( 0.3 )
		_time_since_last_triggered = 0.0

func fade_out( duration: float ):
	if duration <= 0.0:
		_fade = 0.0
		stop()
		return
	_fadeSpeed = -1.0/duration

func fade_in( duration: float ):
	if duration <= 0.0:
		_fade = 1.0
		return
	_fadeSpeed = 1.0/duration

func _on_finished() -> void:
	if _loop:
		play()
