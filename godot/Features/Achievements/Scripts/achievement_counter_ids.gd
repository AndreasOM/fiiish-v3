class_name AchievementCounterIds

enum Id {
	COINS_IN_SINGLE_RUN,
	TOTAL_COINS,
	DISTANCE_IN_SINGLE_RUN,
	TOTAL_DISTANCE,
}


static func to_name( id: AchievementCounterIds.Id ) -> String:
	match id:
		AchievementCounterIds.Id.COINS_IN_SINGLE_RUN:
			return "COINS_IN_SINGLE_RUN"
		AchievementCounterIds.Id.TOTAL_COINS:
			return "TOTAL_COINS"
		AchievementCounterIds.Id.DISTANCE_IN_SINGLE_RUN:
			return "DISTANCE_IN_SINGLE_RUN"
		AchievementCounterIds.Id.TOTAL_DISTANCE:
			return "TOTAL_DISTANCE"
			
	return "[UNKNOWN COUNTER ID %d]" % id
