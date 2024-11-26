extends Object
class_name SkillConfigManager

var _skill_ids: Array = []
var _skills: Dictionary = {}

func _init():
	var sc = SkillConfig.new( SkillIds.Id.MAGNET, "Magnet" )
	
	sc.add_level( 0, SkillLevelConfig.new( 0 )
						.add_effect( SkillEffectIds.Id.MAGNET_RANGE, 1024.0/8 )
						.add_effect( SkillEffectIds.Id.MAGNET_SPEED, 1.0*300.0 )
				)
	sc.add_level( 1, SkillLevelConfig.new( 1 )
						.add_effect( SkillEffectIds.Id.MAGNET_RANGE, 1024.0/7 )
						.add_effect( SkillEffectIds.Id.MAGNET_SPEED, 1.3*300.0 )
				)
	sc.add_level( 2, SkillLevelConfig.new( 2 )
						.add_effect( SkillEffectIds.Id.MAGNET_RANGE, 1024.0/6 )
						.add_effect( SkillEffectIds.Id.MAGNET_SPEED, 1.6*1.6*300.0 )
				)
	sc.add_level( 3, SkillLevelConfig.new( 3 )
						.add_effect( SkillEffectIds.Id.MAGNET_RANGE, 1024.0/5 )
						.add_effect( SkillEffectIds.Id.MAGNET_SPEED, 1.8*1.8*300.0 )
				)
	sc.add_level( 4, SkillLevelConfig.new( 4 )
						.add_effect( SkillEffectIds.Id.MAGNET_RANGE, 1024.0/4 )
						.add_effect( SkillEffectIds.Id.MAGNET_SPEED, 1.9*1.9*300.0 )
				)
	sc.add_level( 5, SkillLevelConfig.new( 5 )
						.add_effect( SkillEffectIds.Id.MAGNET_RANGE, 1024.0/3 )
						.add_effect( SkillEffectIds.Id.MAGNET_SPEED, 2.0*2.0*300.0 )
				)
	self.add( sc )

	sc = SkillConfig.new( SkillIds.Id.MAGNET_BOOST_POWER, "Magnet Boost Power" )
	sc.add_level( 1, SkillLevelConfig.new( 1 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_RANGE, 1.1 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_SPEED, 1.1 )
				)	
	sc.add_level( 2, SkillLevelConfig.new( 2 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_RANGE, 1.5 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_SPEED, 1.5 )
				)
	sc.add_level( 3, SkillLevelConfig.new( 3 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_RANGE, 2.0 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_SPEED, 2.0 )
				)
	sc.add_level( 4, SkillLevelConfig.new( 4 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_RANGE, 2.5 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_SPEED, 2.5 )
				)
	sc.add_level( 5, SkillLevelConfig.new( 5 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_RANGE, 3.0 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_SPEED, 3.0 )
				)
	self.add( sc )

	sc = SkillConfig.new( SkillIds.Id.MAGNET_BOOST_DURATION, "Magnet Boost Duration" )
	sc.add_level( 1, SkillLevelConfig.new( 1 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_DURATION, 1.1 )
				)
	
	sc.add_level( 2, SkillLevelConfig.new( 2 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_DURATION, 1.3 )
				)
	sc.add_level( 3, SkillLevelConfig.new( 3 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_DURATION, 1.6 )
				)
	sc.add_level( 4, SkillLevelConfig.new( 4 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_DURATION, 2.0 )
				)
	sc.add_level( 5, SkillLevelConfig.new( 5 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_DURATION, 2.5 )
				)
	self.add( sc )
	
	sc = SkillConfig.new( SkillIds.Id.COIN_EXPLOSION, "Coin Explosion" )
	sc.add_level( 0, SkillLevelConfig.new( 0 )
						.add_effect( SkillEffectIds.Id.COIN_EXPLOSION_AMOUNT, 3 )
				)
	sc.add_level( 1, SkillLevelConfig.new( 1 )
						.add_effect( SkillEffectIds.Id.COIN_EXPLOSION_AMOUNT, 9 )
				)
	
	sc.add_level( 2, SkillLevelConfig.new( 2 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_RANGE_FACTOR, 27 )
				)
	sc.add_level( 2, SkillLevelConfig.new( 3 )
						.add_effect( SkillEffectIds.Id.MAGNET_BOOST_RANGE_FACTOR, 71 )
				)
	self.add( sc )

	sc = SkillConfig.new( SkillIds.Id.COIN_RAIN, "Coin Rain" )
	sc.add_level( 0, SkillLevelConfig.new( 0 )
						.add_effect( SkillEffectIds.Id.COIN_RAIN_COINS_PER_SECOND, 10 )
						.add_effect( SkillEffectIds.Id.COIN_RAIN_DURATION, 1 )
				)
	sc.add_level( 1, SkillLevelConfig.new( 1 )
						.add_effect( SkillEffectIds.Id.COIN_RAIN_COINS_PER_SECOND, 11 )
						.add_effect( SkillEffectIds.Id.COIN_RAIN_DURATION, 1.1 )
				)
	sc.add_level( 2, SkillLevelConfig.new( 2 )
						.add_effect( SkillEffectIds.Id.COIN_RAIN_COINS_PER_SECOND, 15 )
						.add_effect( SkillEffectIds.Id.COIN_RAIN_DURATION, 1.5 )
				)
	sc.add_level( 3, SkillLevelConfig.new( 3 )
						.add_effect( SkillEffectIds.Id.COIN_RAIN_COINS_PER_SECOND, 18 )
						.add_effect( SkillEffectIds.Id.COIN_RAIN_DURATION, 2 )
				)
	sc.add_level( 4, SkillLevelConfig.new( 4 )
						.add_effect( SkillEffectIds.Id.COIN_RAIN_COINS_PER_SECOND, 22 )
						.add_effect( SkillEffectIds.Id.COIN_RAIN_DURATION, 2.5 )
				)
	sc.add_level( 5, SkillLevelConfig.new( 5 )
						.add_effect( SkillEffectIds.Id.COIN_RAIN_COINS_PER_SECOND, 33 )
						.add_effect( SkillEffectIds.Id.COIN_RAIN_DURATION, 3 )
				)
	self.add( sc )

func add( skill_config: SkillConfig ):
	var id = skill_config.skill_id
	self._skills[ id ] = skill_config
	if !_skill_ids.has( id ):
		_skill_ids.push_back( id )

func get_skill( skill_id: SkillIds.Id) -> SkillConfig:
	return _skills.get( skill_id )
	
func get_skill_level_config( skill_id: SkillIds.Id, level: int) -> SkillLevelConfig:
	var sc = _skills.get( skill_id )
	if sc == null:
		return null
		
	return sc.get_level( level )

func get_skill_ids() -> Array:
	return _skill_ids
