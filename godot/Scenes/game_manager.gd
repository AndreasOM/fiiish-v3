extends Node
class_name GameManager

const EntityType = preload("res://Scripts/entity_type.gd").EntityType
const SoundEffect = preload("res://Scripts/sound_effect.gd").SoundEffect

signal zone_changed

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

var _coins: int = 0
var _distance: float = 0.0
var _paused: bool = true
var current_zone_progress: float = 0.0

var current_zone_width: float:
	get:
		if self._current_zone != null:
			return self._current_zone.width
		else:
			return 0.0

var _current_zone: NewZone = null

var _zone_manager: ZoneManager = null

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
	self._zone_manager = ZoneManager.new()
	
func _ready() -> void:
	self._zone_manager.set_name( "ZoneManager" )
	self.add_child( self._zone_manager )
	
	if OS.has_feature("demo"):
		self._zone_manager.load_zones_from_folder( "res://Resources/Demo-Zones/" )
	else:
		self._zone_manager.load_zones_from_folder( "res://Resources/Zones/" )
	
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
		self._zone_manager.push_next_zone_by_name( iz )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.current_zone_progress += movement_x * delta
	if self._current_zone != null:
		if self.current_zone_progress >= self._current_zone.width:
			self.spawn_zone()
			pass
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


func _pick_next_zone() -> NewZone:
	var blocked_zones: Array[ String ] = [ 
		"0000_Start",
		"0000_ILoveFiiish",
		"0000_ILoveFiiishAndRust",
		"8000_MarketingScreenshots",
		"9998_AssetTest",
		"9999_Test"
	]	
	return self._zone_manager.pick_next_zone( blocked_zones )

func spawn_zone():
	#var xs = [ 1200.0, 1500.0, 1800.0 ]
	#var y = 410.0
	#for x in xs:
		#var o = _rock_b.instantiate()
		#o.game_manager = self
		#o.position = Vector2( x, y )
		#%Obstacles.add_child(o)

	var zone = null
	var next_zone = self._zone_manager.pop_next_zone()
		
	if next_zone >= 0 && next_zone < self._zone_manager.zone_count():
		zone = self._zone_manager.get_zone( next_zone )
	else:
		zone = self._pick_next_zone()
#	if self._zone != null:
	if zone != null:
		self.current_zone_progress = 0.0
		self._current_zone = zone
		self.zone_changed.emit( zone.name)
		Events.broadcast_zone_changed( zone )
		for l in zone.layers.iter():
			if l.name == "Obstacles" || l.name == "Obstacles_01" || l.name == "Pickups_00":
				for obj in l.objects.iter():
	
	
					var o = null
					var ec = entity_config_manager.get_entry( obj.crc )
					if ec != null:
						o = ec.resource.instantiate()
						o.game_manager = self
						o.position = Vector2( obj.pos_x + self.zone_spawn_offset, obj.pos_y )
						o.rotation_degrees = obj.rotation
						match ec.entity_type:
							EntityType.OBSTACLE:
								%Obstacles.add_child(o)
							EntityType.PICKUP:
								%Pickups.add_child(o)
							_ :
								pass
						#print( o )
					else:
						print("Unhandled CRC: %08x" % obj.crc)
						
func cleanup() -> void:
	for o in %Obstacles.get_children():
		%Obstacles.remove_child(o)
		o.queue_free()

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
	self.spawn_zone()

func trigger_sound( fx: SoundEffect ) -> void:
	sound_triggered.emit( fx )

func give_coins( amount: int ) -> void:
	self._coins += amount
