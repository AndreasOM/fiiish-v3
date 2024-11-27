extends Node
class_name GameManager

const EntityType = preload("res://Scripts/entity_type.gd").EntityType
const PickupEffect = preload("res://Scripts/pickup_effect.gd").PickupEffect
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

var _coin_rain_duration: float = 0.0
var _coin_rain_coins_per_second: float = 0.0
var _coin_rain_counter: float = 0.0

var _coins: int = 0
var _distance: float = 0.0
var _paused: bool = true
var current_zone_progress: float = 0.0

var _special_coins_spawned: float = 0.0
var _time_since_last_special_coin: float = 0.0
var _special_coin_streak: int = 0
var _special_coin_cooldown: float = 0.0

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
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var dirs = DirAccess.get_directories_at("res://Resources/")
	for d in dirs:
		print("Dirs: %s" % d)
	var files = DirAccess.get_files_at("res://Resources/")
	for f in files:
		print("Files: %s" % f)
		
	var zones = DirAccess.get_files_at("res://Resources/Zones/")
	for zn in zones:
		print("Zones: %s" % zn)
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
	_distance += self.movement_x * delta

	if _special_coins_spawned > 0.0:
		_special_coins_spawned -= 1.0 * delta
		_special_coins_spawned = max( 0.0, _special_coins_spawned )
		# print("_special_coins_spawned %f" % _special_coins_spawned)
		
	if _time_since_last_special_coin > 0.0:
		_time_since_last_special_coin = max( 0.0, _time_since_last_special_coin - delta )
		
	if _special_coin_cooldown > 0.0:
		_special_coin_cooldown = max( 0.0, _special_coin_cooldown - delta )

#	if Input.is_key_pressed(KEY_D):
#		_distance += 100 * pixels_per_meter
	
#	if Input.is_key_pressed(KEY_C):
#		_coins += 100
			

func _physics_process(delta: float) -> void:
	if !_paused:
		_physics_process_pickups(delta)

func _physics_process_pickups(delta_time: float) -> void:
	for fi in %Fishes.get_children():
		var f = fi as Fish
		if f == null:
			continue
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
						f.trigger_magnet_boost()
						#f.apply_magnet_boost( 3.0, 10.0, 1.5 )
					# :TODO: to be continued...
					PickupEffect.RAIN:
						_coin_rain_duration += f.get_skill_effect_value( SkillEffectIds.Id.COIN_RAIN_DURATION, 0.0 )
						_coin_rain_coins_per_second = f.get_skill_effect_value( SkillEffectIds.Id.COIN_RAIN_COINS_PER_SECOND, 0.0 )
					PickupEffect.EXPLOSION:
						spawn_explosion( pp, f )
					_: pass
				sound_triggered.emit( p.soundEffect() )
				_coins += p.coin_value()
				p.queue_free()
				p.get_parent().remove_child( p )
			elif ls < magnet_range_sqr:
				if !p.is_magnetic():
					continue
				var speed = -magnet_speed * delta_time;
				var l = sqrt(ls);
				speed = max( -l, speed ) 
				delta = delta.normalized()
				delta = speed * delta;
				p.position += delta;
				
		if _coin_rain_duration > 0.0:
			var t = min( delta_time, _coin_rain_duration )
			_coin_rain_counter += t * _coin_rain_coins_per_second
			_coin_rain_duration -= delta_time
			
			var cc = floor(_coin_rain_counter)
			if cc > 0:
				_coin_rain_counter -= cc
				spawn_coins(cc, f)
	
func spawn_explosion( position: Vector2, fish: Fish ):
	position.x += 50.0	
	var count: int = floor(fish.get_skill_effect_value( SkillEffectIds.Id.COIN_EXPLOSION_AMOUNT, 1.0 ))
	
	for i in count:
		var p = _instantiate_coin( fish )
		if p == null:
			continue
		
		p.game_manager = self
		p.position = position
		%Pickups.add_child(p)
		
		var pickup = p as Pickup
		if pickup != null:
			var v = Vector2.RIGHT
			var cone = 0.5
			var a = ( i+0.5 ) * ( ( cone*3.14 )/count ) + (1.5+0.5*cone)*3.14 + randf_range( -0.1, 0.1 )
			var r = randf_range( 1.0, 1.5 )
			v = v.rotated( a )
			v *= 500.0 * r
			v.x += movement_x
			pickup.set_velocity( v )
			pickup.set_target_velocity( Vector2.ZERO, 1.0 * r )
			pickup.disable_magnetic_for_seconds( 1.0 )
	
func _log_special_coin():
	if _time_since_last_special_coin < 3.0:
		_special_coin_streak += 1
		# print("Coin streak %d" % _special_coin_streak)
		if _special_coin_streak > 10:
			_special_coin_cooldown = 10.0
			_special_coin_streak = 0
	
func _pick_coin( fish: Fish ) -> EntityId:
	var luck_factor = max( 0.0, 1.0-0.1*_special_coins_spawned )
	var rain_coin_probability = fish.get_skill_effect_value( SkillEffectIds.Id.RAIN_COIN_PROBABILITY, 0.0 )
	var explosion_coin_probability = fish.get_skill_effect_value( SkillEffectIds.Id.EXPLOSION_COIN_PROBABILITY, 0.0 )

	if _special_coin_cooldown > 0.0:
		luck_factor = 0.0
		
	var r = randf()
	if r < explosion_coin_probability*luck_factor:
		_log_special_coin()
		_special_coins_spawned += 1
		_time_since_last_special_coin = 0.0
		return EntityId.PICKUPEXPLOSION

	r = randf()
	if r < rain_coin_probability*luck_factor:
		_log_special_coin()
		_special_coins_spawned += 1
		_time_since_last_special_coin = 0.0
		return EntityId.PICKUPRAIN
		
	return EntityId.PICKUPCOIN
	
func _instantiate_coin( fish: Fish ) -> Object:
		var coin_entity_id = _pick_coin( fish )
		var coin_ec = _entity_configs.get( coin_entity_id )
		if coin_ec == null:
			return null
		var p = coin_ec.resource.instantiate()
		return p
	
func spawn_coins( count: int, fish: Fish ):
	for i in count:
		var p = _instantiate_coin( fish )
		if p == null:
			continue
			
		p.game_manager = self
		p.position = Vector2( randf_range( 0.0, 1000.0 ), randf_range( -1100.0, -600.0 ) )
		%Pickups.add_child(p)
		
		var pickup = p as Pickup
		if pickup != null:
			pickup.set_velocity( Vector2( randf_range( -10.0, 10.0 ), randf_range( 250.0, 400.0 ) ) )
			
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

func kill_pickups():
	var g = Vector2( 0.0, 9.81*100.0 )
	for pi in %Pickups.get_children():
		var p = pi as Pickup
		if p == null:
			continue
		p.set_acceleration( g )
	
func prepare_respawn():
	_coins = 0
	_coin_rain_duration = 0.0
	_distance = 0.0
	self.push_initial_zones()
	
func goto_next_zone():
	print("Next Zone")
	self.cleanup()
	self.spawn_zone()
