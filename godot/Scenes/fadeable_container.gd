extends CenterContainer
class_name FadeableContainer

var _alpha: float = 1.0
var _alpha_speed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _alpha_speed != 0.0:
		_alpha += _alpha_speed * delta
		if _alpha > 1.0:
			_alpha_speed = 0.0
			_alpha = 1.0
		elif _alpha < 0.0:
			_alpha_speed = 0.0
			_alpha = 0.0
		modulate.a = _alpha
		

func toggle_fade( duration: float ):
	if _alpha == 0.0 || _alpha_speed < 0.0:
		fade_in( duration )
	elif _alpha == 1.0 || _alpha_speed > 0.0:
		fade_out( duration )
		
func fade_in( duration: float):
	mouse_filter = MOUSE_FILTER_STOP
	for c in get_children():
		c.mouse_filter = MOUSE_FILTER_STOP
	if duration > 0.0:
		_alpha_speed = 1.0 / duration
	else:
		print("%s fast fade in" % name)
		_alpha = 1.0
		modulate.a = _alpha
	
func fade_out( duration: float):
	mouse_filter = MOUSE_FILTER_IGNORE
	for c in get_children():
		c.mouse_filter = MOUSE_FILTER_IGNORE
	_alpha_speed = -1.0 / duration
	if duration > 0.0:
		_alpha_speed = -1.0 / duration
	else:
		print("%s fast fade out" % name)
		_alpha = 0.0
		modulate.a = _alpha
	
