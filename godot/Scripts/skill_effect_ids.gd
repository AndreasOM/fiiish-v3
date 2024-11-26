class_name SkillEffectIds

enum Id {
	NONE = 0,
	MAGNET_RANGE_FACTOR = 1,
	MAGNET_BOOST_RANGE_FACTOR = 2,
	# 3
	COIN_EXPLOSION_AMOUNT = 4,
	
	MAGNET_RANGE = 5,
	MAGNET_SPEED = 6,
	MAGNET_BOOST_RANGE = 7,
	MAGNET_BOOST_SPEED = 8,
	MAGNET_BOOST_DURATION = 9,
	COIN_EXPLOSTION_AMOUNT = 10,
	COIN_RAIN_COINS_PER_SECOND = 11,
	COIN_RAIN_DURATION = 12,
}


static func get_name_for_id( id: SkillEffectIds.Id ) -> String:
	match id:
		SkillEffectIds.Id.NONE:
			return "NONE"
		SkillEffectIds.Id.MAGNET_RANGE_FACTOR:
			return "MAGNET_RANGE_FACTOR"
		SkillEffectIds.Id.MAGNET_BOOST_RANGE_FACTOR: 
			return "MAGNET_BOOST_RANGE_FACTOR"
		#SkillEffectIds.Id.COIN_EXPLOSION_AMOUNT: 
		#	return "COIN_EXPLOSION_AMOUNT"

		SkillEffectIds.Id.MAGNET_RANGE: 
			return "MAGNET_RANGE"
		SkillEffectIds.Id.MAGNET_SPEED: 
			return "MAGNET_SPEED"
		SkillEffectIds.Id.MAGNET_BOOST_RANGE: 
			return "MAGNET_BOOST_RANGE"
		SkillEffectIds.Id.MAGNET_BOOST_SPEED: 
			return "MAGNET_BOOST_SPEED"
		SkillEffectIds.Id.MAGNET_BOOST_DURATION: 
			return "MAGNET_BOOST_DURATION"
		SkillEffectIds.Id.COIN_EXPLOSTION_AMOUNT: 
			return "COIN_EXPLOSTION_AMOUNT"
		SkillEffectIds.Id.COIN_RAIN_COINS_PER_SECOND: 
			return "COIN_RAIN_COINS_PER_SECOND"
		SkillEffectIds.Id.COIN_RAIN_DURATION: 
			return "COIN_RAIN_DURATION"
		_:
			return "[UNKNOWN]"
