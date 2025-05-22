class_name DeveloperCommandResetPlayer extends DeveloperCommand

func syntax() -> String:
	return "reset_player"
	
func run( _input: String, game: Game ) -> bool:
	var player = game.get_player()
	player.reset()
	game.get_game_manager().player_changed( player )
	Events.broadcast_global_message( "Reset Player!" )
	return true
	
