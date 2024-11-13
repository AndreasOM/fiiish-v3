class_name SkillEffectIds

enum Id {
	NONE = 0,
	MAGNET_RANGE_FACTOR = 1,
	MAGNET_BOOST_RANGE_FACTOR = 2,
}


static func get_name_for_id( id: SkillEffectIds.Id ) -> String:
	match id:
		SkillEffectIds.Id.NONE:
			return "NONE"
		SkillEffectIds.Id.MAGNET_RANGE_FACTOR:
			return "MAGNET_RANGE_FACTOR"
		SkillEffectIds.Id.MAGNET_BOOST_RANGE_FACTOR: 
			return "MAGNET_BOOST_RANGE_FACTOR"
		_:
			return "[UNKNOWN]"
