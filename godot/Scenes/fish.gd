extends Node2D

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
var _magnet_range: float = 200.0
var _magnet_speed: float = 300.0

var _magnet_range_boost: float = 1.0;
var _magnet_speed_boost: float = 1.0;
var _magnet_boost_duration: float = 0.0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%AnimatedSprite2D.play("swim")
	

func pickup_range() -> float:
	return _pickup_range
	
func magnet_range() -> float:
	return _magnet_range * _magnet_range_boost
	
func magnet_speed() -> float:
	return _magnet_speed * _magnet_speed_boost

func apply_magnet_boost( range_boost: float, speed: float, duration: float ):
	_magnet_range_boost = range_boost
	_magnet_speed_boost = speed
	_magnet_boost_duration = duration
	
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
	self.state = new_state
func _goto_swimming():
	_set_state( Game.State.SWIMMING )
	%GameManager.spawn_zone()
	%GameManager.resume()
	
func _goto_dying() -> void:
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_M):
		self.toggle_mode()
	match self.state:
		Game.State.INITIAL:
			_set_state(Game.State.WAITING_FOR_START)
		Game.State.SWIMMING:
			if Input.is_key_pressed(KEY_SPACE):
				self.direction = Direction.DOWN
			else:
				self.direction = Direction.UP
			if Input.is_key_pressed(KEY_K):
				_goto_dying()
			if _magnet_boost_duration > 0.0:
				_magnet_boost_duration -= delta
				if _magnet_boost_duration < 0.0:
					_magnet_boost_duration = 0.0
					_magnet_range_boost = 1.0
					_magnet_speed_boost = 1.0
		#Game.State.DYING:
			
		Game.State.DEAD:
			if Input.is_key_pressed(KEY_SPACE):
				self._goto_respawning()
		#Game.State.RESPAWNING:
		#	if !Input.is_key_pressed(KEY_SPACE):
		#		_set_state( Game.State.WAITING_FOR_START )
		Game.State.WAITING_FOR_START:
			if Input.is_key_pressed(KEY_SPACE):
				self._goto_swimming()

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
	self.transform.origin.y -= 192.0 * delta
	var a = self.rotation_degrees
	a -= 60.0 * delta
	a = maxf( a, -90.0)
	self.rotation_degrees = a
	if %AnimatedSprite2D.global_position.y < -128.0: # aka off screen
		print("Finished dying (off screen)")
		_set_state( Game.State.DEAD )


func _on_area_2d_area_entered(_area: Area2D) -> void:
	print("Entered")
	_goto_dying()
	pass # Replace with function body.
