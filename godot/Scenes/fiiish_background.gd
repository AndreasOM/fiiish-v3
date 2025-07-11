@tool

extends GradientBackground
class_name FiiishBackground

enum Mode {
	# V1, -> removed
	LOOP,
}
@export var mode: Mode = Mode.LOOP

@export var gradient_texture_swimming: Texture2D = null : set = _set_gradient_texture_swimming
@export var gradient_texture_dying: Texture2D = null
@export var gradient_texture_respawning: Texture2D = null : set = _set_gradient_texture_respawning

#@export_tool_button("Die") var die_button_action = _on_game_state_changed.bind( Game.State.DYING )
#@export_tool_button("Respawn") var respawn_button_action = _on_game_state_changed.bind( Game.State.RESPAWNING )
@export_tool_button("Wait For Start") var wait_for_start_button_action = _on_game_state_changed.bind( Game.State.WAITING_FOR_START )

var _phaseMin: float = 0.0
var _phaseMax: float = 0.0
var _time: float = 0.0

var _tween: Tween = null

func _set_gradient_texture_swimming( t: Texture2D ) -> void:
	gradient_texture_swimming = t
	self.gradient_texture_a = t

func _set_gradient_texture_respawning( t: Texture2D ) -> void:
	gradient_texture_respawning = t
	self.gradient_texture_b = t
	
func _enter_tree() -> void:
	if Engine.is_editor_hint():
		self.gradient_texture_a = gradient_texture_swimming
		self.gradient_texture_b = gradient_texture_respawning
		self.ab_mix = 0.0

func _ready() -> void:
	_phaseMin = 0.0
	_phaseMax = 0.0
	
	super()
	
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
		const eight_hours = 8*60*60
		if _time > eight_hours:
			_time -= eight_hours
		var m = %GameManager.movement
		offset += 0.5*(1.0/1024.0)*m.x
		#offset += 0.5*(1.0/1024.0)*%GameManager.movement_x*delta
		match self.mode:
#			Mode.V1:
#				self._process_mode_v1()
			Mode.LOOP:
				self._process_mode_loop()
		
	super( delta )

#func _process_mode_v1() -> void:
#	var d = _phaseMax - _phaseMin

#	var targetPhase = (0.5 + 0.5 * sin(0.5 * _time)) * d + _phaseMin
#	phase = lerpf(phase,targetPhase,0.01)

func _process_mode_loop() -> void:
	var targetPhase = _time * ( 1.0/ 12.8 )
	
	phase = lerpf(phase,targetPhase,0.01)
	

func _on_game_state_changed(state: Game.State) -> void:
	match self.mode:
#		Mode.V1:
#			self._on_game_state_changed_mode_v1(state)
		Mode.LOOP:
			self._on_game_state_changed_mode_loop(state)
		_:
			pass

func _on_game_state_changed_mode_loop(state: Game.State) -> void:
	match state:
		Game.State.WAITING_FOR_START:
			if self.ab_mix > 0.0:
				push_warning("Switched to WAITING_FOR_START to fast %f" % self.ab_mix )
				self.ab_mix = 0.0
			self.gradient_texture_a = self.gradient_texture_respawning
			self.gradient_texture_b = self.gradient_texture_swimming
				
			if self._tween != null:
				self._tween.kill()
			self._tween = create_tween()
			self._tween.tween_property( self, "ab_mix", 1.0, 1.5 )
		Game.State.SWIMMING:
			if self.ab_mix < 1.0:
				push_warning("Switched to SWIMMING to fast %f" % self.ab_mix )
				self.ab_mix = 1.0
			self.gradient_texture_a = self.gradient_texture_swimming
			self.gradient_texture_b = self.gradient_texture_swimming
			if self._tween != null:
				self._tween.kill()
			
			self.ab_mix = 0.0
		Game.State.DEAD:
			if self.ab_mix > 0.0:
				push_warning("Switched to DEAD to fast %f" % self.ab_mix )
				self.ab_mix = 0.0
			self.gradient_texture_a = self.gradient_texture_swimming
			self.gradient_texture_b = self.gradient_texture_dying
			if self._tween != null:
				self._tween.kill()
			self._tween = create_tween()
			self._tween.tween_property( self, "ab_mix", 1.0, 1.5 )
		Game.State.PREPARING_FOR_START:
			if self.ab_mix < 1.0:
				push_warning("Switched to PREPARING_FOR_START to fast %f" % self.ab_mix )
				self.ab_mix = 1.0
			self.gradient_texture_a = self.gradient_texture_respawning
			self.gradient_texture_b = self.gradient_texture_dying
			if self._tween != null:
				self._tween.kill()
			self._tween = create_tween()
			self._tween.tween_property( self, "ab_mix", 0.0, 1.5 )
			
		_:
			pass
