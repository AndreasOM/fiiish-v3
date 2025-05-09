class_name DeveloperCommandResetLocalLeaderboards extends DeveloperCommand

func syntax() -> String:
	return "reset_local_leaderboards"
	
func run( _input: String, game: Game ) -> bool:
	game.get_player().reset_local_leaderboards()
	return true
	
