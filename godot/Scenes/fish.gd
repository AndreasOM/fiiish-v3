extends Node2D

enum State {
	WAITING_FOR_START,
	SWIMMING,
	DYING,
	DEAD,
	RESPAWNING,
}

enum Direction {
	UP,
	NEUTRAL,
	DOWN
}

var state: State = State.WAITING_FOR_START
var direction: Direction = Direction.NEUTRAL

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%AnimatedSprite2D.play("swim")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match self.state:
		State.SWIMMING:
			if Input.is_key_pressed(KEY_SPACE):
				self.direction = Direction.DOWN
			else:
				self.direction = Direction.UP
			if Input.is_key_pressed(KEY_K):
				%AnimatedSprite2D.play("dying")
				self.state = State.DYING
		#State.DYING:
			
		State.DEAD:
			if Input.is_key_pressed(KEY_SPACE):
				self.transform.origin.y = 0.0
				self.transform.origin.x = -1200.0
				self.rotation_degrees = 0.0
				%AnimatedSprite2D.play("swim")
				self.state = State.RESPAWNING
		#State.RESPAWNING:
		#	if !Input.is_key_pressed(KEY_SPACE):
		#		self.state = State.WAITING_FOR_START
		State.WAITING_FOR_START:
			if Input.is_key_pressed(KEY_SPACE):
				self.state = State.SWIMMING

func _physics_process(delta: float) -> void:
	match self.state:
		State.RESPAWNING:
			_physics_process_respawning(delta)
		State.SWIMMING:
			_physics_process_swimming(delta)
		State.DYING:
			_physics_process_dying(delta)
		#State.DEAD:
		#State.RESPAWNING:
		#State.WAITING_FOR_START:

func _get_angle_range_for_y( y: float ) -> Array[float]:
	var limit: float = 35.0
	var range: float = 1.0/280.0
	var a: float = sin( deg_to_rad( abs( y ) * range ) )
	var m: float = limit * ( 1.0 - a*a*a*a )
	# print(y, "->", limit, " ... ", m, " a=", a )
	if y > 0.0:
		return [ -limit, m ]
	else:
		return [ -m, limit ]

func _physics_process_respawning(delta: float) -> void:
	self.transform.origin.x += 256.0 * delta
	if self.transform.origin.x >= -512.0:
		self.state = State.WAITING_FOR_START


func _physics_process_swimming(delta: float) -> void:
	var a: float = self.rotation_degrees
	
	match self.direction:
		Direction.DOWN:
			a += 120.0 * delta
			pass
		Direction.UP:
			a -= 120.0 * delta
			pass
		#Direction.NEUTRAL:

	var m = _get_angle_range_for_y( self.transform.origin.y )
	# print("!", a, ":", m[ 0 ], " - ", m[ 1 ])
	a = clampf( a, m[ 0 ], m[ 1 ] )
	# print(a)
	self.rotation_degrees = a
	var dy = sin(deg_to_rad(a)) * 350.0 * delta;
	
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
		self.state = State.DEAD
