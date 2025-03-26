class_name DeveloperCommandCheatToggleInvincible extends DeveloperCommand

func syntax() -> String:
	return "cheat_toggle_invincible"
	
func run( input: String, game: Game ) -> bool:
	var cheat_id = CheatIds.Id.INVINCIBLE;
	var player = game.get_player()
	
	if player.isCheatEnabled( cheat_id ):
		print("Disabled INVINCIBLE")
		player.disableCheat( cheat_id )
	else:
		print("Enabled INVINCIBLE")
		player.enableCheat( cheat_id )
		
	Events.broadcast_cheats_changed()
	return true
	
