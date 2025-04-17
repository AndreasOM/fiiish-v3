extends Node
class_name PickupManager

var _special_coins_spawned: float = 0.0
var _time_since_last_special_coin: float = 0.0
var _special_coin_streak: int = 0
var _special_coin_cooldown: float = 0.0

@export var game_manager: GameManager = null
@export var entity_config_manager: EntityConfigManager = null

func _process(delta: float) -> void:

	if _special_coins_spawned > 0.0:
		_special_coins_spawned -= 1.0 * delta
		_special_coins_spawned = max( 0.0, _special_coins_spawned )
		# print("_special_coins_spawned %f" % _special_coins_spawned)

	if _time_since_last_special_coin > 0.0:
		_time_since_last_special_coin = max( 0.0, _time_since_last_special_coin - delta )

	if _special_coin_cooldown > 0.0:
		_special_coin_cooldown = max( 0.0, _special_coin_cooldown - delta )

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
