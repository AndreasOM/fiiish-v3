class_name CheatIds

enum Id {
	NONE = 0,
	INVINCIBLE = 1,
}


static func get_name_for_id( id: CheatIds.Id ) -> String:
	match id:
		CheatIds.Id.NONE:
			return "NONE"
		CheatIds.Id.INVINCIBLE:
			return "INVINCIBLE"
		_:
			return "[UNKNOWN]"
