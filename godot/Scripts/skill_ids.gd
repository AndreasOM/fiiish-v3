class_name SkillIds

enum Id {
	NONE = 0,
	MAGNET_RANGE_FACTOR = 1,
	MAGNET_BOOST_RANGE_FACTOR = 2,
	# 3
	COIN_EXPLOSION = 4,
	COIN_RAIN = 5,
}


static func get_name_for_id( id: SkillIds.Id ) -> String:
	match id:
		SkillIds.Id.NONE:
			return "NONE"
		SkillIds.Id.MAGNET_RANGE_FACTOR:
			return "MAGNET_RANGE_FACTOR"
		SkillIds.Id.MAGNET_BOOST_RANGE_FACTOR: 
			return "MAGNET_BOOST_RANGE_FACTOR"
		SkillIds.Id.COIN_EXPLOSION: 
			return "COIN_EXPLOSION"
		SkillIds.Id.COIN_RAIN: 
			return "COIN_RAIN"
		_:
			return "[UNKNOWN]"
