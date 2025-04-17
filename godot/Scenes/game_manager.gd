extends Node
class_name GameManager

const EntityType = preload("res://Scripts/entity_type.gd").EntityType
const SoundEffect = preload("res://Scripts/sound_effect.gd").SoundEffect

# signal zone_changed

signal sound_triggered( SoundEffect )

@export var movement_x: float = 240.0:
	get:
		if self._paused:
			return 0.0
		else:
			return movement_x

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
		self._zone_config_manager.load_zones_from_folder( "res://Resources/Demo-Zones/" )
	else:
		self._zone_config_manager.load_zones_from_folder( "res://Resources/Zones/" )
	
	self.zone_manager.set_zone_config_manager( self._zone_config_manager )

	self.push_initial_zones()


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
	_distance += self.movement_x * delta

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

func spawn_zone() -> void:
	self.zone_manager.spawn_zone()

func cleanup() -> void:
	self.zone_manager.cleanup()
	self.pickup_manager.cleanup()

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

func trigger_sound( fx: SoundEffect ) -> void:
	sound_triggered.emit( fx )

func give_coins( amount: int ) -> void:
	self._coins += amount

func get_current_zone_progress() -> float:
	return self.zone_manager.current_zone_progress

func get_current_zone_width() -> float:
	return self.zone_manager.current_zone_width
