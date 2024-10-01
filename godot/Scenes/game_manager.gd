extends Node
class_name GameManager

const EntityType = preload("res://Scripts/entity_type.gd").EntityType
const PickupEffect = preload("res://Scripts/pickup_effect.gd").PickupEffect

signal zone_changed
@export var movement_x: float = 240.0:
	get:
		if self._paused:
			return 0.0
		else:
			return movement_x

@export var left_boundary: float = -1200.0
@export var left_boundary_wrap_offset: float = 0	# 0=> destroy instead of wrapping
@export var zone_spawn_offset: float = 0.0

var _coins: int = 0;
var _paused: bool = true
var current_zone_progress: float = 0.0

var current_zone_width: float:
	get:
		if self._current_zone != null:
			return self._current_zone.width
		else:
			return 0.0

var _entity_configs = {
	EntityId.PICKUPCOIN: EntityConfig.new( EntityType.PICKUP, preload("res://Scenes/Pickups/coin.tscn") ),
	EntityId.PICKUPRAIN: EntityConfig.new( EntityType.PICKUP, preload("res://Scenes/Pickups/coin_rain.tscn") ),
	EntityId.PICKUPEXPLOSION: EntityConfig.new( EntityType.PICKUP, preload("res://Scenes/Pickups/coin_explosion.tscn") ),
	EntityId.PICKUPMAGNET: EntityConfig.new( EntityType.PICKUP, preload("res://Scenes/Pickups/magnet.tscn") ),
	EntityId.ROCKA: EntityConfig.new( EntityType.OBSTACLE, preload("res://Scenes/Obstacles/rock_a.tscn") ),
	EntityId.ROCKB: EntityConfig.new( EntityType.OBSTACLE, preload("res://Scenes/Obstacles/rock_b.tscn") ),
	EntityId.ROCKC: EntityConfig.new( EntityType.OBSTACLE, preload("res://Scenes/Obstacles/rock_c.tscn") ),
	EntityId.ROCKD: EntityConfig.new( EntityType.OBSTACLE, preload("res://Scenes/Obstacles/rock_d.tscn") ),
	EntityId.ROCKE: EntityConfig.new( EntityType.OBSTACLE, preload("res://Scenes/Obstacles/rock_e.tscn") ),
	EntityId.ROCKF: EntityConfig.new( EntityType.OBSTACLE, preload("res://Scenes/Obstacles/rock_f.tscn") ),
	EntityId.SEAWEEDA: EntityConfig.new( EntityType.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_a.tscn") ),
	EntityId.SEAWEEDB: EntityConfig.new( EntityType.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_b.tscn") ),
	EntityId.SEAWEEDC: EntityConfig.new( EntityType.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_c.tscn") ),
	EntityId.SEAWEEDD: EntityConfig.new( EntityType.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_d.tscn") ),
	EntityId.SEAWEEDE: EntityConfig.new( EntityType.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_e.tscn") ),
	EntityId.SEAWEEDF: EntityConfig.new( EntityType.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_f.tscn") ),
	EntityId.SEAWEEDG: EntityConfig.new( EntityType.OBSTACLE, preload("res://Scenes/Obstacles/seaweed_g.tscn") ),
}

#var _rock_a = preload("res://Scenes/Obstacles/rock_a.tscn")
#var _rock_b = preload("res://Scenes/Obstacles/rock_b.tscn")
#var _rock_c = preload("res://Scenes/Obstacles/rock_c.tscn")
#var _rock_d = preload("res://Scenes/Obstacles/rock_d.tscn")
#var _rock_e = preload("res://Scenes/Obstacles/rock_e.tscn")
#var _rock_f = preload("res://Scenes/Obstacles/rock_f.tscn")
#var _seaweed_a = preload("res://Scenes/Obstacles/seaweed_a.tscn")
#var _seaweed_b = preload("res://Scenes/Obstacles/seaweed_b.tscn")
#var _seaweed_c = preload("res://Scenes/Obstacles/seaweed_c.tscn")
#var _seaweed_d = preload("res://Scenes/Obstacles/seaweed_d.tscn")
#var _seaweed_e = preload("res://Scenes/Obstacles/seaweed_e.tscn")
#var _seaweed_f = preload("res://Scenes/Obstacles/seaweed_f.tscn")
#var _seaweed_g = preload("res://Scenes/Obstacles/seaweed_g.tscn")

var _zones: Array[ NewZone ] = []
var _next_zones: Array[ int ] = []
var _current_zone: NewZone = null

enum EntityId {
	PICKUPCOIN      = 0xe4c651aa,
	PICKUPRAIN      = 0x06fd4c5a,
	PICKUPEXPLOSION = 0xf75fd92f,
	PICKUPMAGNET    = 0x235a41dd,	
	ROCKA           = 0xd058353c,
	ROCKB           = 0x49516486,
	ROCKC           = 0x3e565410,
	ROCKD           = 0xa032c1b3,
	ROCKE           = 0xd735f125,
	ROCKF           = 0x4e3ca09f,
	SEAWEEDA        = 0x6fe93bef,
	SEAWEEDB        = 0xf6e06a55,
	SEAWEEDC        = 0x81e75ac3,
	SEAWEEDD        = 0x1f83cf60,
	SEAWEEDE        = 0x6884fff6,
	SEAWEEDF        = 0xf18dae4c,
	SEAWEEDG        = 0x868a9eda,
}


func coins() -> int:
	return _coins

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var zones = DirAccess.get_files_at("res://Resources/Zones/")
	for zn in zones:
		var fzn = "res://Resources/Zones/%s" % zn
		var z = load( fzn )
		self._zones.push_back(z )
	
	self.push_initial_zones()	


func push_initial_zones():
	# var initial_zones = [ "0000_Start", "0000_ILoveFiiish" ]
	var initial_zones = [ "0000_ILoveFiiish" ]
	for iz in initial_zones:
		for i in range( 0,self._zones.size() ):
			var z = self._zones[ i ];
			if z.name == iz:
				self._next_zones.push_back( i )
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.current_zone_progress += movement_x * delta
	if self._current_zone != null:
		if self.current_zone_progress >= self._current_zone.width:
			self.spawn_zone()
			pass
	pass

func _physics_process(delta: float) -> void:
	if !_paused:
		_physics_process_pickups(delta)

func _physics_process_pickups(delta_time: float) -> void:
	for f in %Fishes.get_children():
		if !f.is_alive():
			continue
		var pickup_range_sqr = f.pickup_range() * f.pickup_range();
		var magnet_range_sqr = f.magnet_range() * f.magnet_range();
		var magnet_speed = f.magnet_speed();
		var fp = f.position
		
		for p in %Pickups.get_children():
			if !p.is_alive():
				continue
			
			var pp = p.position
			var delta = pp - fp
			var ls = delta.length_squared()
			
			if ls < pickup_range_sqr:
				# :TODO: pickup
				p.collect()
				match p.effect():
					PickupEffect.MAGNET:
						f.apply_magnet_boost( 3.0, 10.0, 1.5 )
					# :TODO: to be continued...
					_: pass
				_coins += p.coin_value()
				p.queue_free()
				p.get_parent().remove_child( p )
			elif ls < magnet_range_sqr:
				var speed = -magnet_speed * delta_time;
				delta = delta.normalized()
				delta = speed * delta;
				p.position += delta;
				
	
func pause():
	self._paused = true

func resume():
	self._paused = false


func _pick_next_zone() -> NewZone:
	var blocked_zones = [ 
		"0000_Start",
		"0000_ILoveFiiish",
		"0000_ILoveFiiishAndRust",
		"8000_MarketingScreenshots",
		"9998_AssetTest",
		"9999_Test"
	]
	var next_zone = null
	
	# warning deadlock if all zones are blocked
	while next_zone == null:
		next_zone = self._zones.pick_random()
		if blocked_zones.find( next_zone.name ) >= 0:
			next_zone = null
		
	return next_zone
	
func spawn_zone():
	#var xs = [ 1200.0, 1500.0, 1800.0 ]
	#var y = 410.0
	#for x in xs:
		#var o = _rock_b.instantiate()
		#o.game_manager = self
		#o.position = Vector2( x, y )
		#%Obstacles.add_child(o)

	var zone = null
	var next_zone = -1
	if self._next_zones.size() > 0:
		next_zone = self._next_zones.pop_front()
		
	if next_zone >= 0 && next_zone < self._zones.size():
		zone = self._zones[ next_zone ]
	else:
		zone = self._pick_next_zone()
#	if self._zone != null:
	if zone != null:
		self.current_zone_progress = 0.0
		self._current_zone = zone
		self.zone_changed.emit( zone.name)
		for l in zone.layers:
			if l.name == "Obstacles" || l.name == "Obstacles_01" || l.name == "Pickups_00":
				for obj in l.objects:
	
	
					var o = null
					var ec = _entity_configs.get( obj.crc )
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
						
func cleanup():
	for o in %Obstacles.get_children():
		%Obstacles.remove_child(o)
		o.queue_free()

	for p in %Pickups.get_children():
		%Pickups.remove_child(p)
		p.queue_free()

func prepare_respawn():
	_coins = 0
	self.push_initial_zones()
	
func goto_next_zone():
	print("Next Zone")
	self.cleanup()
	self.spawn_zone()
