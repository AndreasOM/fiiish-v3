extends CenterContainer
class_name FadeableContainer

var _alpha: float = 1.0
var _alpha_speed: float = 0.0

var _original_z_index = RenderingServer.CANVAS_ITEM_Z_MIN

signal on_fading_in
signal on_faded_in
signal on_fading_out
signal on_faded_out

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("%s z: %d" % [ name, z_index ] )
	_save_original_z_index()
	pass # Replace with function body.

func _save_original_z_index():
	if _original_z_index == RenderingServer.CANVAS_ITEM_Z_MIN:
		print("Saving original z_index for %s: %d <= %d" % [ name, _original_z_index, z_index ] )
		_original_z_index = z_index

func _restore_original_z_index():
	if _original_z_index != RenderingServer.CANVAS_ITEM_Z_MIN:
		print("Restoring original z_index for %s: %d => %d" % [ name, _original_z_index, z_index ] )
		z_index = _original_z_index
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if _alpha_speed != 0.0:
		_alpha += _alpha_speed * delta
		if _alpha > 1.0:
			_alpha_speed = 0.0
			_alpha = 1.0
			on_faded_in.emit()
		elif _alpha < 0.0:
			_alpha_speed = 0.0
			_alpha = 0.0
			visible = false
			z_index = RenderingServer.CANVAS_ITEM_Z_MIN
			on_faded_out.emit()
		modulate.a = _alpha
		

func toggle_fade( duration: float ):
	if _alpha == 0.0 || _alpha_speed < 0.0:
		fade_in( duration )
	elif _alpha == 1.0 || _alpha_speed > 0.0:
		fade_out( duration )
		
func fade_in( duration: float):
	_restore_original_z_index()
	# z_index = _original_z_index
	visible = true
	mouse_filter = MOUSE_FILTER_STOP
	for c in get_children():
		c.mouse_filter = MOUSE_FILTER_STOP
	if duration > 0.0:
		_alpha_speed = 1.0 / duration
		on_fading_in.emit()
	else:
		print("%s fast fade in" % name)
		_alpha = 1.0
		modulate.a = _alpha
		on_fading_in.emit()
		on_faded_in.emit()
	
func fade_out( duration: float):
	mouse_filter = MOUSE_FILTER_IGNORE
	for c in get_children():
		c.mouse_filter = MOUSE_FILTER_IGNORE
	_alpha_speed = -1.0 / duration
	if duration > 0.0:
		_alpha_speed = -1.0 / duration
		on_fading_out.emit()
	else:
		print("%s fast fade out" % name)
		_alpha = 0.0
		modulate.a = _alpha
		visible = false
		_save_original_z_index()
		z_index = RenderingServer.CANVAS_ITEM_Z_MIN
		on_fading_out.emit()
		on_faded_out.emit()
	
