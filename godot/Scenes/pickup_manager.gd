extends Node
class_name PickupManager

var _special_coins_spawned: float = 0.0
var _time_since_last_special_coin: float = 0.0
var _special_coin_streak: int = 0
var _special_coin_cooldown: float = 0.0

var _coin_rain_duration: float = 0.0
var _coin_rain_coins_per_second: float = 0.0
var _coin_rain_counter: float = 0.0

@export var game_manager: GameManager = null
@export var entity_config_manager: EntityConfigManager = null

func cleanup():
	for p in %Pickups.get_children():
		%Pickups.remove_child(p)
		p.queue_free()

func kill_all() -> void:
	var g = Vector2( 0.0, 9.81*100.0 )
	for pi in %Pickups.get_children():
		var p = pi as Pickup
		if p == null:
			continue
		p.set_acceleration( g )

func prepare_respawn():
	_coin_rain_duration = 0.0

func _process(delta: float) -> void:

	if _special_coins_spawned > 0.0:
		_special_coins_spawned -= 1.0 * delta
		_special_coins_spawned = max( 0.0, _special_coins_spawned )
		# print("_special_coins_spawned %f" % _special_coins_spawned)

	if _time_since_last_special_coin > 0.0:
		_time_since_last_special_coin = max( 0.0, _time_since_last_special_coin - delta )

	if _special_coin_cooldown > 0.0:
		_special_coin_cooldown = max( 0.0, _special_coin_cooldown - delta )

	if !self.game_manager.game.is_in_zone_editor():
		self._despawn_offscreen_pickups()

func _despawn_offscreen_pickups() -> void:
	var cs: CollisionShape2D = self.game_manager.game_zone
	var s: Shape2D = cs.shape
	var r: Rect2 = s.get_rect()
	
	for p in %Pickups.get_children():
		var n = p as Node2D
		if n == null:
			continue

		if !r.has_point( n.position ):
		#if position.x < self.game_manager.left_boundary:
			var wo = self.game_manager.left_boundary_wrap_offset
			if wo > 0:
				n.position.x += wo
			else:
				%Pickups.remove_child(p)
				p.queue_free()

func _physics_process(delta: float) -> void:
	if !self.game_manager.should_process_pickups():
		return

	_physics_process_fish_attraction( delta )
	_physics_process_coins( delta )

func _physics_process_fish_attraction( delta: float ) -> void:
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
			var delta_pos = pp - fp
			var ls = delta_pos.length_squared()
			
			if ls < pickup_range_sqr:
				p.collect()
				match p.effect():
					PickupEffectIds.Id.MAGNET:
						f.trigger_magnet_boost()
					PickupEffectIds.Id.RAIN:
						var duration := f.get_skill_effect_value( SkillEffectIds.Id.COIN_RAIN_DURATION, 0.0 )
						var coins_per_second := f.get_skill_effect_value( SkillEffectIds.Id.COIN_RAIN_COINS_PER_SECOND, 0.0 )
						extend_coin_rain( duration, coins_per_second )
					PickupEffectIds.Id.EXPLOSION:
						spawn_explosion( pp, f )
					_: pass
				self.game_manager.trigger_sound( p.soundEffect() )
				self.game_manager.give_coins( p.coin_value() )
				p.queue_free()
				p.get_parent().remove_child( p )
			elif ls < magnet_range_sqr:
				if !p.is_magnetic():
					continue
				var speed = -magnet_speed * delta;
				var l = sqrt(ls);
				speed = max( -l, speed ) 
				delta_pos = delta_pos.normalized()
				delta_pos = speed * delta_pos;
				p.position += delta_pos;

func _physics_process_coins(delta: float) -> void:
	for fi in %Fishes.get_children():
		var f = fi as Fish
		if f == null:
			continue
		if !f.is_alive():
			continue
		if _coin_rain_duration > 0.0:
			var t = min( delta, _coin_rain_duration )
			_coin_rain_counter += t * _coin_rain_coins_per_second
			_coin_rain_duration -= delta
			
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
		
		p.game_manager = self.game_manager
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
			# forward speed of explosion
			v.x += 240.0
			#v.x += self.game_manager.play_movement.x
			#v.x += self.game_manager.movement_x
			pickup.set_velocity( v )
			pickup.set_target_velocity( Vector2.ZERO, 1.0 * r )
			pickup.disable_magnetic_for_seconds( 1.0 )

func extend_coin_rain( duration: float, cps: float ):
	_coin_rain_duration += duration
	_coin_rain_coins_per_second = cps

func spawn_coins( count: int, fish: Fish ):
	for i in count:
		var p = _instantiate_coin( fish )
		if p == null:
			continue
			
		p.game_manager = self.game_manager
		p.position = Vector2( randf_range( 0.0, 1000.0 ), randf_range( -1100.0, -600.0 ) )
		%Pickups.add_child(p)
		
		var pickup = p as Pickup
		if pickup != null:
			pickup.set_velocity( Vector2( randf_range( -10.0, 10.0 ), randf_range( 250.0, 400.0 ) ) )

func _instantiate_coin( fish: Fish ) -> Object:
	var coin_entity_id = pick_coin( fish )
	var coin_ec = entity_config_manager.get_entry( coin_entity_id )
	if coin_ec == null:
		return null
	var p = coin_ec.resource.instantiate()
	return p

func pick_coin( fish: Fish ) -> EntityId.Id:
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
		return EntityId.Id.PICKUPEXPLOSION

	r = randf()
	if r < rain_coin_probability*luck_factor:
		_log_special_coin()
		_special_coins_spawned += 1
		_time_since_last_special_coin = 0.0
		return EntityId.Id.PICKUPRAIN
		
	return EntityId.Id.PICKUPCOIN

func _log_special_coin():
	if _time_since_last_special_coin < 3.0:
		_special_coin_streak += 1
		# print("Coin streak %d" % _special_coin_streak)
		if _special_coin_streak > 10:
			_special_coin_cooldown = 10.0
			_special_coin_streak = 0
