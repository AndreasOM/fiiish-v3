class_name EntityTypes

enum Id {
	NONE,
	PICKUP,
	OBSTACLE,
	AREA,
}

static func id_to_string(id: Id) -> String:
	match id:
		Id.NONE:
			return "NONE"
		Id.PICKUP:
			return "PICKUP"
		Id.OBSTACLE:
			return "OBSTACLE"
		Id.AREA:
			return "AREA"
		_:
			return "[UNKNOWN]"
