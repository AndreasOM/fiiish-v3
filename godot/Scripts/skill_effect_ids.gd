class_name SkillEffectIds

enum Id {
	NONE = 0,
	MAGNET_RANGE_FACTOR = 1,
	MAGNET_BOOST_RANGE_FACTOR = 2,
	# 3
	COIN_EXPLOSION_AMOUNT = 4,
}


static func get_name_for_id( id: SkillEffectIds.Id ) -> String:
	match id:
		SkillEffectIds.Id.NONE:
			return "NONE"
		SkillEffectIds.Id.MAGNET_RANGE_FACTOR:
			return "MAGNET_RANGE_FACTOR"
		SkillEffectIds.Id.MAGNET_BOOST_RANGE_FACTOR: 
			return "MAGNET_BOOST_RANGE_FACTOR"
		SkillEffectIds.Id.COIN_EXPLOSION_AMOUNT: 
			return "COIN_EXPLOSION_AMOUNT"
		_:
			return "[UNKNOWN]"
