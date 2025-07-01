@tool
class_name WindowAlignedSprite2D
extends Sprite2D

@export var horizontal_alignment: float = 0.0 : set = set_horizontal_alignment
@export var vertical_alignment: float = 0.0 : set = set_vertical_alignment
@export var cover: bool = false : set = set_cover

var _needs_relayout: bool = true

func _ready() -> void:
	get_window().size_changed.connect(_on_window_size_changed)
	
func _on_window_size_changed() -> void:
	self._needs_relayout = true
	
func set_horizontal_alignment( a: float ) -> void:
	horizontal_alignment = a
	self._needs_relayout = true

func set_vertical_alignment( a: float ) -> void:
	vertical_alignment = a
	self._needs_relayout = true
	
func set_cover( c: bool ) -> void:
	cover = c
	self._needs_relayout = true
	
func _process(delta: float) -> void:
	if !self._needs_relayout:
		return
	if self.texture == null:
		push_warning("No texture")
		return
	self._needs_relayout = false
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

	var scale_x = ww / 1920.0
	var scale_y = wh / 1080.0
	var scale = 1.0
	if scale_x >= scale_y:
		scale = scale_y
		scale_x /= scale_y
		scale_y = 1.0
	else:
		scale = scale_x
		scale_y /= scale_x
		scale_x = 1.0
#
	if !Engine.is_editor_hint():
		print("scale_x: ", scale_x)
		print("scale_y: ", scale_y)
		print("scale  : ", scale)

	
	var img_scale = 1.0
	var iw = self.texture.get_image().get_width()
	var ih = self.texture.get_image().get_height()
	
	if self.cover:
		print( "iwxih %dx%d" % [ iw, ih ] )
		var ish = wh / float(ih)
		var isw = ww / float(iw)
		img_scale = max(ish,isw)
		img_scale /= scale
		iw *= img_scale
		ih *= img_scale
		print("img_scale  : ", img_scale)

	
	#var aw = ww-iw
	var aw = scale_x*1920-iw
	#var ah = wh-ih
	var ah = scale_y*1080-ih
	
	self.position.x = ( 0.0 + 0.5*iw + ( horizontal_alignment + 1.0 )*0.5 * aw )
	self.position.y = ( 0.0 + 0.5*ih + ( vertical_alignment + 1.0 )*0.5 * ah )
		
	
	self.scale.x = img_scale
	self.scale.y = img_scale
	
