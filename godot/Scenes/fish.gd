extends Node2D
class_name Fish

@export var invincible_color: Color = Color.ORANGE_RED
@export var invincible_hurt_color: Color = Color.DARK_GREEN

signal state_changed( state: Game.State )

# Moved into Game
#enum State {
#	WAITING_FOR_START,
#	SWIMMING,
#	DYING,
#	DEAD,
#	RESPAWNING,
#}

enum Direction {
	UP,
	NEUTRAL,
	DOWN
}

enum Mode {
	PLAY,
	TEST,
}

var state: Game.State = Game.State.INITIAL
var direction: Direction = Direction.NEUTRAL
var mode: Mode = Mode.PLAY

var _pickup_range: float = 10.0
#var _magnet_range: float = 1.0
#var _magnet_speed: float = 1.0

var _magnet_range_boost: float = 1.0
var _magnet_speed_boost: float = 1.0
var _magnet_boost_duration: float = 0.0

var _magnet_range_factor: float = 1.0
var _magnet_speed_factor: float = 1.0

var _skill_effect_set: SkillEffectSet = SkillEffectSet.new()

var _velocity: Vector2 = Vector2.ZERO
var _acceleration: Vector2 = Vector2.ZERO

var _is_invincible: bool = false
var _initial_modulate: Color = Color.WHITE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initial_modulate = self.modulate
	%AnimatedSprite2D.play("swim")
	
func set_acceleration( acceleration: Vector2 ):
	_acceleration = acceleration

func pickup_range() -> float:
	return _pickup_range
	
func magnet_range() -> float:
	#return _magnet_range * _magnet_range_factor * _magnet_range_boost
	return _magnet_range_factor * _magnet_range_boost
	
func magnet_speed() -> float:
	# return _magnet_speed * _magnet_speed_factor * _magnet_speed_boost
	return _magnet_speed_factor * _magnet_speed_boost

func trigger_magnet_boost():
	_magnet_range_boost = _skill_effect_set.get_value(SkillEffectIds.Id.MAGNET_BOOST_RANGE, 1.0)
	_magnet_speed_boost = _skill_effect_set.get_value(SkillEffectIds.Id.MAGNET_BOOST_SPEED, 1.0)
	_magnet_boost_duration = _skill_effect_set.get_value(SkillEffectIds.Id.MAGNET_BOOST_DURATION, 1.0)
	
#func apply_magnet_boost( range_boost: float, speed: float, duration: float ):
#	_magnet_range_boost = range_boost
#	_magnet_speed_boost = speed
#	_magnet_boost_duration = duration
	
func is_alive() -> bool:
	match state:
		Game.State.WAITING_FOR_START:	return false;
		Game.State.SWIMMING:        		return true;
		Game.State.DYING:           		return false;
		Game.State.DEAD:            		return false;
		Game.State.RESPAWNING:      		return false;
	return false
		
func _set_state( new_state: Game.State ):
	state_changed.emit( new_state )
	Events.broadcast_state_changed( new_state )
	self.state = new_state

func _goto_swimming():
	_set_state( Game.State.SWIMMING )
	%GameManager.spawn_zone()
	%GameManager.resume()
	
func _goto_dying() -> void:
	#set_acceleration(Vector2( 0.0, -9.81*100.0 ))
	set_acceleration(Vector2( 0.0, -9.81*50.0 ))
	_set_state( Game.State.DYING )
	%GameManager.pause()
	%AnimatedSprite2D.play("dying")

func _goto_respawning():
	_set_state( Game.State.RESPAWNING )
	self.transform.origin.y = 0.0
	self.transform.origin.x = -1200.0
	self.rotation_degrees = 0.0
	%GameManager.cleanup()
	%GameManager.prepare_respawn()
	%AnimatedSprite2D.play("swim")
		

func toggle_mode():
	match self.mode:
		Mode.PLAY:
			self.mode = Mode.TEST
		Mode.TEST:
			self.mode = Mode.PLAY

func _unhandled_input(event: InputEvent) -> void:
	match self.state:
		Game.State.SWIMMING:
			if event.is_action("swim_down"):
				if event.is_pressed():
					self.direction = Direction.DOWN
				else:
					self.direction = Direction.UP
		Game.State.DEAD:
			if event.is_action_pressed("swim_down"):
				self._goto_respawning()
		Game.State.WAITING_FOR_START:
			if event.is_action_pressed("swim_down"):
				self._goto_swimming()
				self.direction = Direction.DOWN
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:		
	if Input.is_key_pressed(KEY_M):
		self.toggle_mode()
	match self.state:
		Game.State.INITIAL:
			_set_state(Game.State.WAITING_FOR_START)
		Game.State.SWIMMING:
			if Input.is_key_pressed(KEY_K):
				_goto_dying()
			if _magnet_boost_duration > 0.0:
				_magnet_boost_duration -= delta
				if _magnet_boost_duration < 0.0:
					_magnet_boost_duration = 0.0
					_magnet_range_boost = 1.0
					_magnet_speed_boost = 1.0

		
func _physics_process(delta: float) -> void:
	match self.state:
		Game.State.RESPAWNING:
			_physics_process_respawning(delta)
		Game.State.SWIMMING:
			_physics_process_swimming(delta)
		Game.State.DYING:
			_physics_process_dying(delta)
		#Game.State.DEAD:
		#Game.State.RESPAWNING:
		#Game.State.WAITING_FOR_START:

func _get_angle_range_for_y( y: float ) -> Array[float]:
	var limit: float = 35.0
	var r: float = 1.0/280.0
	# var a: float = sin( deg_to_rad( abs( y ) * r ) )
	var a: float = sin( abs( y ) * r )
	var m: float = limit * ( 1.0 - a*a*a*a )
	# print(y, "->", limit, " ... ", m, " a=", a )
	if y > 0.0:
		return [ -limit, m ]
	else:
		return [ -m, limit ]

func _physics_process_respawning(delta: float) -> void:
	self.transform.origin.x += 256.0 * delta
	if self.transform.origin.x >= -512.0:
		_set_state( Game.State.WAITING_FOR_START )
		


func _physics_process_swimming(delta: float) -> void:
	if self.mode != Mode.PLAY:
		return
		
	var a: float = self.rotation_degrees
	
	match self.direction:
		Direction.DOWN:
			a += 120.0 * delta
			pass
		Direction.UP:
			a -= 120.0 * delta
			pass
		#Direction.NEUTRAL:

	var y =  self.transform.origin.y
	var m = _get_angle_range_for_y( y )
	var na = clampf( a, m[ 0 ], m[ 1 ] )
	# print( "! %5.2f at %5.2f: %5.2f - %5.2f -> %5.2f" % [ a, y, m[0], m[1], na ])
	self.rotation_degrees = na
	var dy = sin(deg_to_rad(na)) * 350.0 * delta;
	
	self.transform.origin.y += dy
 	
func _physics_process_dying(delta: float) -> void:
	# print("Dying: %s" % %AnimatedSprite2D.global_position)
	_velocity += _acceleration * delta
	# self.transform.origin.y -= 192.0 * delta
	self.transform.origin += _velocity * delta
	var a = self.rotation_degrees
	a -= 60.0 * delta
	a = maxf( a, -90.0)
	self.rotation_degrees = a
	if %AnimatedSprite2D.global_position.y < -128.0: # aka off screen
		print("Finished dying (off screen)")
		_velocity = Vector2.ZERO
		_acceleration = Vector2.ZERO
		_set_state( Game.State.DEAD )


func _on_area_2d_area_entered(_area: Area2D) -> void:
	print("Entered")
	if self._is_invincible:
		self.modulate = self.invincible_hurt_color
		await get_tree().create_timer(0.25).timeout
		self.modulate = self.invincible_color
		return
	_goto_dying()
	pass # Replace with function body.

#func apply_skills( player: Player, scm: SkillConfigManager ):
#	var id = SkillIds.Id.MAGNET_RANGE_FACTOR
#	var magnet_level = player.get_skill_level( id )
#	var skill_level_config = scm.get_skill_level_config( id, magnet_level )
#	if skill_level_config != null:
#		var effect_value = skill_level_config.get_effect( SkillEffectIds.Id.MAGNET_RANGE_FACTOR, 1.0 )
#		_magnet_range_factor = effect_value
#	else:
#		_magnet_range_factor = 1.0
#
#	print("Magnet Range Factor %f" % _magnet_range_factor )

func set_skill_effect_set( ses: SkillEffectSet ):
	_skill_effect_set = ses
	_magnet_range_factor = _skill_effect_set.get_value( SkillEffectIds.Id.MAGNET_RANGE, 1.0 )
	_magnet_speed_factor = _skill_effect_set.get_value( SkillEffectIds.Id.MAGNET_SPEED, 1.0 )
	print("Magnet Range Factor %f" % _magnet_range_factor )
	print("Magnet Speed Factor %f" % _magnet_speed_factor )

func get_skill_effect_value( skill_effect_id: SkillEffectIds.Id, default: float):
	return _skill_effect_set.get_value( skill_effect_id, default)

func set_invincible( invicible: bool ):
	if self._is_invincible == invicible:
		return
	if invicible:
		self._is_invincible = true
		print("Fish started being invicible")
		self.modulate = self.invincible_color
	else:
		self._is_invincible = false
		print("Fish stopped being invicible")
		self.modulate = self._initial_modulate
