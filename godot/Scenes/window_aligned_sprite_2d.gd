@tool
class_name WindowAlignedSprite2D
extends Sprite2D

@export var horizontal_alignment: float = 0.0
@export var vertical_alignment: float = 0.0
@export var cover: bool = false

@export var extra_offset: Vector2 = Vector2.ZERO

func _process(delta: float) -> void:

	#var ww = get_viewport_rect().size.x
	#var wh = get_viewport_rect().size.y
	var ws = get_window().size
	var ww = get_window().size.x
	var wh = get_window().size.y
	if Engine.is_editor_hint():
		ww = 1920
		wh = 1080
	else:
		print("ws: ", ws)
		#print("scale: ", self.get_global_transform().get_scale())
		pass

#		ww = 1920
#		wh = 1080
		
	var scale_x = ww / 1920.0
	var scale_y = wh / 1080.0
	var scale = 1.0
	if scale_x >= scale_y:
		scale = scale_y
		scale_x /= scale_y
		scale_y = 1.0
		#scale_x = scale_y
		#scale_y = 1.0
		pass
	else:
		scale = scale_x
		scale_y /= scale_x
		scale_x = 1.0
		# scale_y = 1.0
		#scale_x = 1.0
		pass
#
	##scale_x = 1.0
	#var scale = min(scale_x,scale_y)
	##scale = scale_y
	## scale = 2.0
	##scale = 1.0
	#if scale_x >= scale_y:
		## wide
		##scale_y = 1.0
		#pass
	#else:
		## high
		##scale_x = 1.0
		#pass
	
	#scale = max(1.0, scale)
	if !Engine.is_editor_hint():
		print("scale_x: ", scale_x)
		print("scale_y: ", scale_y)
		print("scale  : ", scale)

#	scale_x = max(1.0, scale_x)
#	scale_y = max(1.0, scale_y)
	
	var img_scale = min(1.0, scale)

	var iw = img_scale*self.texture.get_image().get_width()
	var ih = img_scale*self.texture.get_image().get_height()
	
	#var aw = ww-iw
	var aw = scale_x*1920-iw
	#var ah = wh-ih
	var ah = scale_y*1080-ih
	
	self.position.x = ( 0.0 + 0.5*iw + ( horizontal_alignment + 1.0 )*0.5 * aw )
	self.position.y = ( 0.0 + 0.5*ih + ( vertical_alignment + 1.0 )*0.5 * ah )
		
	
	#self.position.x = 1920*scale_x + extra_offset.x
	#self.position.y = 1080*scale_y + extra_offset.y
	#self.scale.x = scale
	#self.scale.y = scale
	
