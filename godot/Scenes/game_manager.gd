extends Node
class_name GameManager

signal sound_triggered( soundEffects_Id )
@export var game: Game = null
@export var play_movement: Vector2 = Vector2( 240.0, 0.0 )

var movement: Vector2 = Vector2( 0.0, 0.0 )

@export var pixels_per_meter: float = 100.0

@export var left_boundary: float = -1200.0
@export var left_boundary_wrap_offset: float = 0	# 0=> destroy instead of wrapping
@export var zone_spawn_offset: float = 0.0

@export var game_zone: CollisionShape2D = null

@export var entity_config_manager: EntityConfigManager = null
@export var pickup_manager: PickupManager = null
@export var zone_manager: ZoneManager = null

var _coins: int = 0
var _distance: float = 0.0
var _paused: bool = true

var _zone_config_manager: ZoneConfigManager = null

func is_paused() -> bool:
	return self._paused
	
func should_process_pickups() -> bool:
	return !self._paused && !game.is_in_zone_editor()

func coins() -> int:
	return _coins

func distance_in_m() -> int:
	return floor(_distance/pixels_per_meter)

func take_coins() -> int:
	var c = _coins;
	_coins = 0
	return c
	
func take_current_distance_in_meters() -> int:
	var d = distance_in_m();
	_distance = 0
	return d

		
func _init() -> void:
	self._zone_config_manager = ZoneConfigManager.new()

func _ready() -> void:
	self._zone_config_manager.set_name( "ZoneConfigManager" )
	self.add_child( self._zone_config_manager )
	
	if OS.has_feature("demo"):
		self._zone_config_manager.load_zones_from_folder( "res://Resources/Demo-Zones/", "classic" )
	else:
		self._zone_config_manager.load_zones_from_folder( "res://Resources/Zones/", "classic" )
		self._zone_config_manager.load_zones_from_folder( "user://zones/", "user" )
	
	self.zone_manager.set_zone_config_manager( self._zone_config_manager )

	self.push_initial_zones()

	Events.zone_edit_enabled.connect( _on_zone_edit_enabled )
	Events.zone_edit_disabled.connect( _on_zone_edit_disabled )

func set_invincible( invicible: bool ):
	for fi in %Fishes.get_children():
		var f = fi as Fish
		if f == null:
			continue
		f.set_invincible( invicible )
	
func push_initial_zones():
	# var initial_zones = [ "0000_Start", "0000_ILoveFiiish" ]
	var initial_zones = [ "0000_ILoveFiiish" ]
	for iz in initial_zones:
		self._zone_config_manager.push_next_zone_by_name( iz )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_distance += self.movement.x
	# _distance += self.movement_x * delta

	if game.is_in_zone_editor():
		# self.movement = Vector2.ZERO
		# handled by set_move
		pass
	else:
		if self._paused:
			self.movement = Vector2.ZERO
			#var frame = Engine.get_frames_drawn()
			#print( "GameManager [%d](%f) %f %f" % [ frame, delta, self.movement.x, self.play_movement.x ])
		else:
			self.movement = play_movement * delta
			#var frame = Engine.get_frames_drawn()
			#print( "GameManager [%d](%f) %f %f" % [ frame, delta, self.movement.x, self.play_movement.x ])

#	if Input.is_key_pressed(KEY_D):
#		_distance += 100 * pixels_per_meter
	
#	if Input.is_key_pressed(KEY_C):
#		_coins += 100
			

#func _physics_process(delta: float) -> void:
#	if !_paused:
#		_physics_process_pickups(delta)
				
func pause():
	self._paused = true

func resume():
	self._paused = false

func spawn_zone( autospawn_on_zone_end: bool = false ) -> void:
	self.zone_manager.spawn_zone( autospawn_on_zone_end )

func cleanup() -> void:
	self.zone_manager.cleanup()
	self.pickup_manager.cleanup()

func goto_dying_without_result() -> void:
	for fi in %Fishes.get_children():
		var f = fi as Fish
		if f == null:
			continue
		f._goto_dying_without_result()
	
func kill_pickups() -> void:
	self.pickup_manager.kill_all()
	
func prepare_respawn() -> void:
	_coins = 0
	_distance = 0.0
	self.pickup_manager.prepare_respawn()
	self.push_initial_zones()
	
func goto_next_zone():
	print("Next Zone")
	self.cleanup()
	self.zone_manager.spawn_zone()

func trigger_sound( soundEffect_Id: SoundEffects.Id ) -> void:
	sound_triggered.emit( soundEffect_Id )

func give_coins( amount: int ) -> void:
	self._coins += amount

func get_current_zone_progress() -> float:
	return self.zone_manager.current_zone_progress

func get_current_zone_width() -> float:
	return self.zone_manager.current_zone_width

func set_move( m: Vector2 ) -> void:
	self.movement = m
	
func move_fish( v: Vector2 ) -> void:
	for fi in %Fishes.get_children():
		var f = fi as Fish
		if f == null:
			continue
		f.move( v )

func _on_zone_edit_enabled() -> void:
	for fi in %Fishes.get_children():
		var f = fi as Fish
		if f == null:
			continue
		f.goto_edit_mode()

func _on_zone_edit_disabled() -> void:
	for fi in %Fishes.get_children():
		var f = fi as Fish
		if f == null:
			continue
		f.goto_play_mode()

func get_zone_config_manager() -> ZoneConfigManager:
	return self._zone_config_manager
