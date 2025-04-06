class_name DeveloperCommandGiveCoins1000 extends DeveloperCommand

func syntax() -> String:
	return "give_coins_1000"
	
func run( input: String, game: Game ) -> bool:
	game.get_player().give_coins( 1000 )
	return true
	
