class_name DeveloperCommandGiveCoins1000 extends DeveloperCommand

func syntax() -> String:
	return "reset_player"
	
func run( input: String, game: Game ) -> bool:
	game.get_player().reset()
	return true
	
