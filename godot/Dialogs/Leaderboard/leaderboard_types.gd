class_name LeaderboardTypes

enum Type {
	NONE,
	LOCAL_COINS,
	LOCAL_DISTANCE,
	STEAM_SINGLE_RUN_COINS,
	STEAM_SINGLE_RUN_DISTANCE,
}

static func type_to_name( type: LeaderboardTypes.Type ) -> String:
	match type:
		LeaderboardTypes.Type.NONE:
			return "NONE"
		LeaderboardTypes.Type.LOCAL_COINS:
			return "LOCAL_COINS"
		LeaderboardTypes.Type.LOCAL_DISTANCE:
			return "LOCAL_DISTANCE"
		LeaderboardTypes.Type.STEAM_SINGLE_RUN_COINS:
			return "STEAM_SINGLE_RUN_COINS"
		LeaderboardTypes.Type.STEAM_SINGLE_RUN_DISTANCE:
			return "STEAM_SINGLE_RUN_DISTANCE"
		_:
			return "[UNKNOWN LEADERBOARD_TYPE]"
