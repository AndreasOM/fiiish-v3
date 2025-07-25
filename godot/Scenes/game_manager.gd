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

@onready var fish_manager: FishManager = %FishManager

var _coins: int = 0
var _distance: float = 0.0
var _paused: bool = true

var _zone_config_manager: ZoneConfigManager = null

var _test_zone_filename: String = ""

var _rolling_counter_coins_10_seconds: RollingCounter = null

func is_paused() -> bool:
	return self._paused
	
func should_process_pickups() -> bool:
	return !self._paused && !game.is_in_zone_editor()

func coins() -> int:
	return _coins

func distance_in_m() -> int:
	return floor(_distance/pixels_per_meter)
	
func m_to_distance( m: int ) -> float:
	return (m*pixels_per_meter)

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
	
	self.entity_config_manager.load_entites_from_folder( "res://Resources/Entities/" )
	
	self._zone_config_manager.set_name( "ZoneConfigManager" )
	self.add_child( self._zone_config_manager )
	
	if OS.has_feature("demo"):
		self._zone_config_manager.load_zones_from_folder( "res://Resources/Demo-Zones/", "classic" )
	else:
		self._zone_config_manager.load_zones_from_folder( "res://Resources/Zones/", "classic" )

	DirAccess.make_dir_recursive_absolute("user://zones/")
	self._zone_config_manager.load_zones_from_folder( "user://zones/", "user" )
	
	self.zone_manager.set_zone_config_manager( self._zone_config_manager )

	self.push_initial_zones()

	Events.game_state_changed.connect( _on_game_state_changed )
	Events.zone_finished.connect( _on_zone_finished )
	

	self._rolling_counter_coins_10_seconds = RollingCounter.new( 10.0, 0.5 )
	self._rolling_counter_coins_10_seconds.name = "Rolling Counter Coins 10 Seconds"
	self.add_child( self._rolling_counter_coins_10_seconds )

	
func set_invincible( invicible: bool ) -> void:
	self.fish_manager.set_invincible( invicible )
	
func push_initial_zones() -> void:
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
			
			if !self.has_test_zone():
				var achievement_counter_manager = self.game.achievement_counter_manager
				var d = distance_in_m();
				achievement_counter_manager.set_counter( AchievementCounterIds.Id.DISTANCE_IN_SINGLE_RUN, d )
				var old_d = self.game.get_player().total_distance()
				achievement_counter_manager.set_counter( AchievementCounterIds.Id.TOTAL_DISTANCE, old_d + d )
				var c = coins()
				achievement_counter_manager.set_counter( AchievementCounterIds.Id.COINS_IN_SINGLE_RUN, c )
				var total_coins = self.game.get_player().total_coins() + c
				achievement_counter_manager.set_counter( AchievementCounterIds.Id.TOTAL_COINS, total_coins )
				var max_coins = self.game.get_player().max_coins()
				var player_coins = self.game.get_player().coins()
				max_coins = max( max_coins, player_coins + c )
				achievement_counter_manager.set_counter( AchievementCounterIds.Id.MAX_COINS, max_coins )
				var coins_10_seconds = self._rolling_counter_coins_10_seconds.get_total()
				# print("Coins 10 seconds: %d" % coins_10_seconds )
				achievement_counter_manager.set_counter( AchievementCounterIds.Id.COINS_PER_10_SECONDS, coins_10_seconds )
				# is a node now! # self._achievement_manager._process( delta )

#	if Input.is_key_pressed(KEY_D):
#		_distance += 100 * pixels_per_meter
	
#	if Input.is_key_pressed(KEY_C):
#		_coins += 100
			

#func _physics_process(delta: float) -> void:
#	if !_paused:
#		_physics_process_pickups(delta)
				
func pause() -> void:
	self._paused = true

func resume() -> void:
	self._paused = false

func spawn_zone( autospawn_on_zone_end: bool = false ) -> void:
	self.zone_manager.spawn_zone( autospawn_on_zone_end )

func cleanup() -> void:
	self.zone_manager.cleanup()
	self.pickup_manager.cleanup()

func kill_all_fishes() -> void:
	self.fish_manager.kill_all_fishes()
	
func kill_pickups() -> void:
	self.pickup_manager.kill_all()
	
func prepare_respawn() -> void:
	_coins = 0
	_distance = 0.0
	self.pickup_manager.prepare_respawn()
	self._zone_config_manager.clear_next_zones()
	if self._test_zone_filename.is_empty():
		self.push_initial_zones()
	else:
		self._zone_config_manager.push_next_zone_by_filename( self._test_zone_filename )
	
func goto_next_zone() -> void:
	# probably not used for a long time
	print("Next Zone")
	self.cleanup()
	if !self._test_zone_filename.is_empty():
		self._zone_config_manager.push_next_zone_by_filename( self._test_zone_filename )
	self.zone_manager.spawn_zone()

func trigger_sound( soundEffect_Id: SoundEffects.Id ) -> void:
	sound_triggered.emit( soundEffect_Id )

func give_coins( amount: int ) -> void:
	self._coins += amount
	self._rolling_counter_coins_10_seconds.increment( amount )
	
func set_coins( value: int ) -> void:
	self._coins = value

func set_distance_in_m( value: int ) -> void:
	self._distance = self.m_to_distance(value)

func get_current_zone_progress() -> float:
	return self.zone_manager.current_zone_progress

func get_current_zone_width() -> float:
	return self.zone_manager.current_zone_width

func set_move( m: Vector2 ) -> void:
	self.movement = m
	
func move_fish( v: Vector2 ) -> void:
	self.fish_manager.move_fish( v )

func _on_game_state_changed( state: Game.State ) -> void:
	match state:
		Game.State.SWIMMING:
			var autospawn = self._test_zone_filename.is_empty()
			self.spawn_zone( autospawn )
			self.resume()
		_:
			pass
	
func _on_zone_finished() -> void:
	if !self._test_zone_filename.is_empty():
		self._zone_config_manager.push_next_zone_by_filename( self._test_zone_filename )
		self.zone_manager.spawn_zone( false )

func get_zone_config_manager() -> ZoneConfigManager:
	return self._zone_config_manager
	
func set_test_zone_filename( filename: String ) -> void:
	self._test_zone_filename = filename
	
func clear_test_zone_filename( ) -> void:
	self._test_zone_filename = ""

func has_test_zone() -> bool:
	return !self._test_zone_filename.is_empty()
