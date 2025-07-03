extends AudioStreamPlayer
class_name MusicManager

var _fade: float = 0.0
var _fadeSpeed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _fadeSpeed != 0.0:
		_fade += _fadeSpeed*delta
		if _fade >= 1.0:
			_fade = 1.0
			_fadeSpeed = 0.0
		elif _fade <= 0.0:
			_fade = 0.0
			set_stream_paused( true )
			_fadeSpeed = 0.0
		volume_db = linear_to_db(_fade)
		
func fade_in( duration: float) -> void:
	print("Unpausing stream")
	set_stream_paused( false )
	if ! is_playing():
		play()

	if duration <= 0.0:
		_fade = 1.0
		return
	_fadeSpeed = 1.0/duration
	
func fade_out( duration: float) -> void:
	if duration <= 0.0:
		_fade = 0.0
		set_stream_paused( true )
		return
	_fadeSpeed = -1.0/duration
