class_name GameModes

enum Mode {
	CLASSIC,
	ARCADE,
	ADVENTURE,
}


static func next( mode: GameModes.Mode ) -> GameModes.Mode:
	match mode:
		GameModes.Mode.CLASSIC:
			return GameModes.Mode.ARCADE
		GameModes.Mode.ARCADE:
			return GameModes.Mode.ADVENTURE
		GameModes.Mode.ARCADE:
			return GameModes.Mode.CLASSIC
		_:
			return GameModes.Mode.CLASSIC
	
static func get_name_for_mode( mode: GameModes.Mode ) -> String:
	match mode:
		GameModes.Mode.CLASSIC:
			return "Classic"
		GameModes.Mode.ARCADE:
			return "Arcade"
		GameModes.Mode.ADVENTURE:
			return "Adventure"
		_:
			return "[UNKNOWN]"
