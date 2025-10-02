class_name DeveloperCommandResume extends DeveloperCommand

func syntax() -> String:
	return "resume"
	
func run( _input: String, game: Game ) -> bool:
	# NEW PAUSE SYSTEM: Request resume
	if game.get_fiiish_pause_manager() != null:
		game.get_fiiish_pause_manager().get_pause_manager().request_player_resume()
	return true
	
