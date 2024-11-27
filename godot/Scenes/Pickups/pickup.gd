extends Node2D
class_name Pickup

const PickupEffect = preload("res://Scripts/pickup_effect.gd").PickupEffect
const SoundEffect = preload("res://Scripts/sound_effect.gd").SoundEffect

@export var game_manager: GameManager = null

@export var _coin_value: int = 0
@export var _effect: PickupEffect = PickupEffect.NONE
@export var _soundEffect: SoundEffect = SoundEffect.NONE

var _velocity: Vector2 = Vector2.ZERO

var _target_velocity: Vector2 = Vector2.ZERO
var _start_velocity: Vector2 = Vector2.ZERO
var _velocity_change_duration: float = 0.0
var _velocity_change_time: float = 0.0


var _disable_magnetic_duration: float = 0.0

var _acceleration: Vector2 = Vector2.ZERO

func set_velocity( velocity: Vector2 ):
	_velocity = velocity
	_velocity_change_duration = 0.0
	
func set_target_velocity( velocity: Vector2, duration: float ):
	_start_velocity = _velocity
	_target_velocity = velocity
	_velocity_change_duration = duration
	_velocity_change_time = 0.0

func set_acceleration( acceleration: Vector2 ):
	_acceleration = acceleration

func is_alive() -> bool:
	return true

func is_magnetic() -> bool:
	return _disable_magnetic_duration <= 0.0
	
func disable_magnetic_for_seconds( duration: float ):
	_disable_magnetic_duration = duration
	
func collect():
	pass

func effect() -> PickupEffect:
	return _effect

func soundEffect() -> SoundEffect:
	return _soundEffect

func coin_value() -> int:
	return _coin_value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var as2d = self.get_node("%AnimatedSprite2D")
	if as2d != null:
		as2d.play("default")

func _process(delta: float) -> void:
	if _disable_magnetic_duration > 0.0:
		_disable_magnetic_duration -= delta
	
	if _velocity_change_duration > _velocity_change_time:
		_velocity_change_time += delta
		var p = _velocity_change_time / _velocity_change_duration
		_velocity = _start_velocity.lerp( _target_velocity, p )

func _physics_process(delta: float) -> void:
	_velocity += _acceleration * delta;
	
	if self.game_manager != null:
		var m = Vector2( -self.game_manager.movement_x, 0.0 )
		m += _velocity
		m *= delta
		# var mx = self.game_manager.movement_x
		# self.transform.origin.x -= mx * delta
		self.transform.origin += m 
		# :TODO: use Area2D
		var cs: CollisionShape2D = self.game_manager.game_zone
		var s: Shape2D = cs.shape
		var r: Rect2 = s.get_rect()
		
		if !r.has_point( position ):
		#if position.x < self.game_manager.left_boundary:
			var wo = self.game_manager.left_boundary_wrap_offset
			if wo > 0:
				position.x += wo
			else:
				queue_free()
