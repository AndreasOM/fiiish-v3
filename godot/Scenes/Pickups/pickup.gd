extends Entity
class_name Pickup

@export var _coin_value: int = 0
@export var _effect: PickupEffectIds.Id = PickupEffectIds.Id.NONE
@export var _soundEffect: SoundEffects.Id = SoundEffects.Id.NONE

var _velocity: Vector2 = Vector2.ZERO

var _target_velocity: Vector2 = Vector2.ZERO
var _start_velocity: Vector2 = Vector2.ZERO
var _velocity_change_duration: float = 0.0
var _velocity_change_time: float = 0.0


var _disable_magnetic_duration: float = 0.0

var _acceleration: Vector2 = Vector2.ZERO

func set_velocity( velocity: Vector2 ) -> void:
	_velocity = velocity
	_velocity_change_duration = 0.0
	
func set_target_velocity( velocity: Vector2, duration: float ) -> void:
	_start_velocity = _velocity
	_target_velocity = velocity
	_velocity_change_duration = duration
	_velocity_change_time = 0.0

func set_acceleration( acceleration: Vector2 ) -> void:
	_acceleration = acceleration

func is_alive() -> bool:
	return true

func is_magnetic() -> bool:
	return _disable_magnetic_duration <= 0.0
	
func disable_magnetic_for_seconds( duration: float ) -> void:
	_disable_magnetic_duration = duration
	
func collect() -> void:
	pass

func effect() -> PickupEffectIds.Id:
	return _effect

func soundEffect() -> SoundEffects.Id:
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

	_velocity += _acceleration * delta;
	
	if self.game_manager != null:
		var m = self.game_manager.movement
		var v = _velocity * delta
		m = v - m
		#var m = Vector2( -self.game_manager.movement_x, 0.0 )
		#m += _velocity
		#m *= delta
		# var mx = self.game_manager.movement_x
		# self.transform.origin.x -= mx * delta
		self.transform.origin += m 

#func draw_minimap( n: Node2D, scale: float ) -> void:
#	var radius = 15.0
#	n.draw_circle( (self.global_position)*scale, radius*scale, Color.YELLOW, false, 3.0 )
#	#n.draw_circle( (self.global_position -0.5* Vector2(radius,radius))*scale, radius*scale, Color.YELLOW, false, 3.0 )
	
