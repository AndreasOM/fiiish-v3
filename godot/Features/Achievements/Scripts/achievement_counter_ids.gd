class_name AchievementCounterIds

enum Id {
	COINS_IN_SINGLE_RUN,
	TOTAL_COINS,
	DISTANCE_IN_SINGLE_RUN,
	TOTAL_DISTANCE,
	PLAYED_BEFORE_JUNE_2025,
	PLAY_COUNT,
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
		AchievementCounterIds.Id.PLAYED_BEFORE_JUNE_2025:
			return "PLAYED_BEFORE_JUNE_2025"
			
	return "[UNKNOWN COUNTER ID %d]" % id
