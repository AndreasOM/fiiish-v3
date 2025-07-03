@tool
extends TextureRect
class_name GradientBackground

@export var tint: Color = Color.WHITE

@export var gradient_texture_a: Texture2D = null : set = set_gradient_texture_a
@export var gradient_texture_b: Texture2D = null : set = set_gradient_texture_b

@export var offset: float = 0.0 : set = set_shader_offset
@export var phase: float = 0.0 : set = set_phase
@export var ab_mix: float = 0.0 : set = set_ab_mix

func set_shader_offset( o: float ) -> void:
	offset = o
	material.set_shader_parameter("offset", offset)

func get_shader_offset( ) -> float:
	return offset

func set_phase( p: float ) -> void:
	phase = p
	material.set_shader_parameter("phase", phase)

func set_ab_mix( d: float ) -> void:
	ab_mix = d
	material.set_shader_parameter("ab_mix", ab_mix)
	
func set_gradient_texture_a( t: Texture2D ) -> void:
	gradient_texture_a = t
	material.set_shader_parameter("gradient_a", gradient_texture_a)

func set_gradient_texture_b( t: Texture2D ) -> void:
	gradient_texture_b = t
	material.set_shader_parameter("gradient_b", gradient_texture_b)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.set_shader_parameter("tint", tint)
	material.set_shader_parameter("gradient_a", gradient_texture_a)
	material.set_shader_parameter("gradient_b", gradient_texture_b)
	material.set_shader_parameter("offset", offset)
	material.set_shader_parameter("phase", phase)
	if !Engine.is_editor_hint():
		self.ab_mix = 0.0

	phase = 0.0
	get_viewport().connect("size_changed", _on_viewport_resize)
	_fix_size()
	
func _on_viewport_resize() -> void:
	# print("_on_viewport_resize")
	_fix_size()
	
func _fix_size() -> void:
	# var screensize = get_window().size
	var viewport = get_viewport()
	if viewport != null:
		var screensize = viewport.size
		var s = screensize.y/1024.0
		var repeat = screensize.x/1024.0
		repeat /= s
		repeat = ceil(repeat)
		repeat = floor( 0.5*repeat )*2+1
		size.x = 1024*repeat
		position.x = -0.5*size.x

func _process(_delta: float) -> void:
#	material.set_shader_parameter("offset", offset)
#	material.set_shader_parameter("phase", phase)
#	material.set_shader_parameter("ab_mix", ab_mix)
	pass
