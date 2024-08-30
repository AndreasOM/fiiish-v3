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
				%AnimationPlayer.play("dying")
				self.state = State.DYING
		#State.DYING:
			
		State.DEAD:
			if Input.is_key_pressed(KEY_SPACE):
				self.transform.origin.y = 0.0
				%AnimatedSprite2D.play("swim")
				%AnimationPlayer.play("respawn")
				self.state = State.RESPAWNING
		State.RESPAWNING:
			if !Input.is_key_pressed(KEY_SPACE):
				self.state = State.WAITING_FOR_START
		State.WAITING_FOR_START:
			if Input.is_key_pressed(KEY_SPACE):
				self.state = State.SWIMMING

func _physics_process(delta: float) -> void:
	match self.state:
		State.SWIMMING:
			_physics_process_swimming(delta)
		State.DYING:
			_physics_process_dying(delta)
		#State.DEAD:
		#State.RESPAWNING:
		#State.WAITING_FOR_START:
		
func _physics_process_swimming(delta: float) -> void:
	match self.direction:
		Direction.DOWN:
			self.transform.origin.y += 100.0 * delta
		Direction.UP:
			self.transform.origin.y -= 100.0 * delta
		#Direction.NEUTRAL:
	
func _physics_process_dying(delta: float) -> void:
	# print("Dying: %s" % %AnimatedSprite2D.global_position)
	#self.transform.origin.y -= 300.0 * delta
	if %AnimatedSprite2D.global_position.y < 0: # aka off screen
		print("Finished dying (off screen)")
		self.state = State.DEAD


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"dying":
			if self.state == State.DYING:
				print("Finished dying (animation)")
				self.state = State.DEAD
