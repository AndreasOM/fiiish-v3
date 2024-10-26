extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().get_viewport().connect("size_changed", _on_viewport_resize)
	_fix_size()
#func _enter_tree() -> void:
#	material.set_shader_parameter("tint", tint)

func _on_viewport_resize():
	_fix_size()
	
func _fix_size():
	var screensize =  get_viewport().size
	var a = screensize.x*1.0/screensize.y*1.0
	var sx = screensize.x/1920.0
	var sy = screensize.y/1080.0
	var target_aspect = 1920.0/1080.0
	var tx = 1080.0 * target_aspect * sy
	print("%dx%d %f, %f %f -> tx %f" % [ screensize.x, screensize.y, a, sx, sy, tx])
	
	# var scale = screensize.y/1024.0
	# scale *= 1080.0/1024.0
	var scale = 1080.0/1024.0
	if a < target_aspect:
		var s = target_aspect/a
		scale *= s
	self.scale.x = scale
	self.scale.y = scale
	# position.x = 0.5 *screensize.x #0.5*960*scale # 960*scale
	# position.x = 0.5 *screensize.x*scale #0.5*960*scale # 960*scale
	#position.x = ( 0.5 * 1920.0 + 0.25  * screensize.x )*scale
	# position.x = ( 0.5 * screensize.x )*scale
	#if sx < sy:
	#	position.x = 960
	#else:
	#	position.x = screensize.x
	var ar = max(1.0,sx/sy)
	position.x = 960.0 * ar
	position.y = 512*scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
