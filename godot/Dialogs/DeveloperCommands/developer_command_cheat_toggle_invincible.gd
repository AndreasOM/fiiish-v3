class_name DeveloperCommandCheatToggleInvincible extends DeveloperCommand

func syntax() -> String:
	return "cheat_toggle_invincible"
	
func run( _input: String, game: Game ) -> bool:
	var cheat_id = CheatIds.Id.INVINCIBLE;
	var player = game.get_player()
	
	if player.is_cheat_enabled( cheat_id ):
		print("Disabled INVINCIBLE")
		player.disable_cheat( cheat_id )
	else:
		print("Enabled INVINCIBLE")
		player.enable_cheat( cheat_id )
		
	Events.broadcast_cheats_changed()
	return true
	
