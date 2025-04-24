@tool
extends TextureRect

enum Mode {
	V1,
	LOOP,
}
@export var mode: Mode = Mode.V1
@export var tint: Color = Color.WHITE

@export var gradientTexture: Texture2D = null : set = set_gradientTexture
@export var gradient_texture_b: Texture2D = null : set = set_gradient_texture_b

@export var gradient_texture_swimming: Texture2D = null
@export var gradient_texture_dying: Texture2D = null
@export var gradient_texture_respawning: Texture2D = null

@export var offset: float = 0.0
@export var phase: float = 0.5
@export var desaturate: float = 0.0

var _phaseMin: float = 0.0
var _phaseMax: float = 0.0
var _time: float = 0.0

func set_gradientTexture( t: Texture2D ) -> void:
	gradientTexture = t
	material.set_shader_parameter("gradient", gradientTexture)

func set_gradient_texture_b( t: Texture2D ) -> void:
	gradient_texture_b = t
	material.set_shader_parameter("gradient_b", gradient_texture_b)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material.set_shader_parameter("tint", tint)
	material.set_shader_parameter("gradient", gradientTexture)
	material.set_shader_parameter("gradient_b", gradient_texture_b)
	material.set_shader_parameter("offset", offset)
	material.set_shader_parameter("phase", phase)
	if !Engine.is_editor_hint():
		self.desaturate = 0.0

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
#	if Engine.is_editor_hint():
#		# material.set_shader_parameter("tint", tint)
#		# material.set_shader_parameter("gradient", gradientTexture)
#		# material.set_shader_parameter("gradient_b", gradient_texture_b)
#		match self.mode:
#			Mode.V1:
#				# self._process_mode_v1()
#				pass
#			Mode.LOOP:
#				# self._process_mode_loop()
#				pass
		
	if !Engine.is_editor_hint():
		_time += delta
		offset += 0.5*(1.0/1024.0)*%GameManager.movement_x*delta
		match self.mode:
			Mode.V1:
				self._process_mode_v1()
			Mode.LOOP:
				self._process_mode_loop()
		
	material.set_shader_parameter("offset", offset)
	material.set_shader_parameter("phase", phase)
	material.set_shader_parameter("desaturate", desaturate)

func _process_mode_v1() -> void:
	var d = _phaseMax - _phaseMin

	var targetPhase = (0.5 + 0.5 * sin(0.5 * _time)) * d + _phaseMin
	phase = lerpf(phase,targetPhase,0.01)
	# phase = targetPhase

func _process_mode_loop() -> void:
	var targetPhase = _time * ( 1.0/ 12.8 )
	
	phase = lerpf(phase,targetPhase,0.01)
	
func _on_game_state_changed(state: Game.State) -> void:
	match self.mode:
		Mode.V1:
			self._on_game_state_changed_mode_v1(state)
		Mode.LOOP:
			self._on_game_state_changed_mode_loop(state)
		_:
			pass
			
func _on_game_state_changed_mode_v1(state: Game.State):
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

func _on_game_state_changed_mode_loop(state: Game.State):
	match state:
		Game.State.WAITING_FOR_START:
			self.gradientTexture = self.gradient_texture_swimming
			self.gradient_texture_b = self.gradient_texture_respawning
			if self.desaturate > 0.0:
				push_warning("Switched to WAITING_FOR_START to fast %f" % self.desaturate )
				
			self.desaturate = 1.0 - self.desaturate
			var tween = create_tween()
			tween.tween_property( self, "desaturate", 0.0, 3.0 )
		Game.State.SWIMMING:
			pass
		Game.State.DYING:
			self.gradientTexture = self.gradient_texture_swimming
			self.gradient_texture_b = self.gradient_texture_dying
			var tween = create_tween()
			tween.tween_property( self, "desaturate", 1.0, 3.0 )
			
		Game.State.DEAD:
			pass
		Game.State.RESPAWNING:
			self.gradientTexture = self.gradient_texture_respawning
			self.gradient_texture_b = self.gradient_texture_dying
			var tween = create_tween()
			tween.tween_property( self, "desaturate", 0.0, 1.0 )
			
		_:
			pass
