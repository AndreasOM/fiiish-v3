class_name AchievementCounterIds

enum Id {
	COINS_IN_SINGLE_RUN,
	TOTAL_COINS,
	DISTANCE_IN_SINGLE_RUN,
	TOTAL_DISTANCE,
	PLAYED_BEFORE_JUNE_2025,
	PLAY_COUNT,
	MAX_COINS,
	SKILL_UPGRADES,
	DAY_STREAK,
	COINS_PER_10_SECONDS,
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
		AchievementCounterIds.Id.MAX_COINS:
			return "MAX_COINS"
		AchievementCounterIds.Id.SKILL_UPGRADES:
			return "SKILL_UPGRADES"
		AchievementCounterIds.Id.DAY_STREAK:
			return "DAY_STREAK"
		AchievementCounterIds.Id.COINS_PER_10_SECONDS:
			return "COINS_PER_10_SECONDS"
			
	return "[UNKNOWN COUNTER ID %d]" % id
