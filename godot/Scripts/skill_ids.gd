class_name SkillIds

enum Id {
	NONE = 0,
	MAGNET_RANGE_FACTOR = 1,
	MAGNET_BOOST_RANGE_FACTOR = 2,
	# 3
	COIN_EXPLOSION_V1 = 4,
	COIN_RAIN_V1 = 5,
	
	MAGNET = 6,
	MAGNET_BOOST_POWER = 7,
	MAGNET_BOOST_DURATION = 8,
	COIN_EXPLOSION = 9,
	COIN_RAIN = 10,
}


static func get_name_for_id( id: SkillIds.Id ) -> String:
	match id:
		SkillIds.Id.NONE:
			return "NONE"
		SkillIds.Id.MAGNET_RANGE_FACTOR:
			return "MAGNET_RANGE_FACTOR"
		SkillIds.Id.MAGNET_BOOST_RANGE_FACTOR: 
			return "MAGNET_BOOST_RANGE_FACTOR"
		SkillIds.Id.COIN_EXPLOSION_V1: 
			return "COIN_EXPLOSION_V1"
		SkillIds.Id.COIN_RAIN_V1: 
			return "COIN_RAIN_V1"

		SkillIds.Id.MAGNET: 
			return "MAGNET"
		SkillIds.Id.MAGNET_BOOST_POWER: 
			return "MAGNET_BOOST_POWER"
		SkillIds.Id.MAGNET_BOOST_DURATION: 
			return "MAGNET_BOOST_DURATION"
		SkillIds.Id.COIN_EXPLOSION: 
			return "COIN_EXPLOSION"
		SkillIds.Id.COIN_RAIN: 
			return "COIN_RAIN"
		_:
			return "[UNKNOWN]"
