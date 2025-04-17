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

@export var entity_config_manager: EntityConfigManager = null
@export var pickup_manager: PickupManager = null

var _coin_rain_duration: float = 0.0
var _coin_rain_coins_per_second: float = 0.0
var _coin_rain_counter: float = 0.0

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
				self.pickup_manager.spawn_coins(cc, f)
	
func spawn_explosion( position: Vector2, fish: Fish ):
	position.x += 50.0	
	var count: int = floor(fish.get_skill_effect_value( SkillEffectIds.Id.COIN_EXPLOSION_AMOUNT, 1.0 ))
	
	for i in count:
		var p = self.pickup_manager._instantiate_coin( fish )
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
