@tool
extends TextureRect

@export var tint: Color = Color.WHITE

@export var gradientTexture: Texture2D = null

@export var offset: float = 0.0
@export var phase: float = 0.5

var _phaseMin: float = 0.0
var _phaseMax: float = 0.0
var _time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.set_shader_parameter("tint", tint)
	material.set_shader_parameter("gradient", gradientTexture)
	material.set_shader_parameter("offset", offset)
	material.set_shader_parameter("phase", phase)
	phase = 0.0
	_phaseMin = 0.0
	_phaseMax = 0.0
	get_viewport().connect("size_changed", _on_viewport_resize)
	_fix_size()
#func _enter_tree() -> void:
#	material.set_shader_parameter("tint", tint)

func _on_viewport_resize():
	# print("_on_viewport_resize")
	_fix_size()
	
func _fix_size():
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		material.set_shader_parameter("tint", tint)
		material.set_shader_parameter("gradient", gradientTexture)
		# phase = 0.5
		
	if !Engine.is_editor_hint():
		_time += delta
		offset += 0.5*(1.0/1024.0)*%GameManager.movement_x*delta
		var d = _phaseMax - _phaseMin

		var targetPhase = (0.5 + 0.5 * sin(0.5 * _time)) * d + _phaseMin
		phase = lerpf(phase,targetPhase,0.01)
		# phase = targetPhase
		
	material.set_shader_parameter("offset", offset)
	material.set_shader_parameter("phase", phase)


func _on_game_state_changed(state: Game.State) -> void:
	match state:
		Game.State.WAITING_FOR_START:
			# (16.0 / 128.0, 96.0 / 128.0)
			_phaseMin = 16.0/128.0
			_phaseMax = 96.0/128.0
			phase = 0.0
		Game.State.SWIMMING:
			# (16.0 / 128.0, 96.0 / 128.0)
			_phaseMin = 16.0/128.0
			_phaseMax = 96.0/128.0
		Game.State.DYING:
			# (112.0 / 128.0, 112.0 / 128.0)
			_phaseMin = 112.0/128.0
			_phaseMax = 112.0/128.0
			# print("Dying %f - %f" % [ _phaseMin, _phaseMax ] )
		Game.State.DEAD:
			# (112.0 / 128.0, 112.0 / 128.0)
			_phaseMin = 112.0/128.0
			_phaseMax = 112.0/128.0
		Game.State.RESPAWNING:
			# (127.0 / 128.0, 127.0 / 128.0)	
			_phaseMin = 127.0/128.0
			_phaseMax = 127.0/128.0
		_:
			pass
