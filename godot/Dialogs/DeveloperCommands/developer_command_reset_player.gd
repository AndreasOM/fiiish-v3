class_name DeveloperCommandResetPlayer extends DeveloperCommand

func syntax() -> String:
	return "reset_player"
	
func run( _input: String, game: Game ) -> bool:
	var player = game.get_player()
	player.reset()
	player.save()
	var achievement_manager = game.achievement_manager
	if achievement_manager != null:
		achievement_manager.reset_achievements()
	var achievement_counter_manager = game.achievement_counter_manager
	if achievement_counter_manager != null:
		achievement_counter_manager.reset_counters()
	Events.broadcast_player_changed( player )
	Events.broadcast_global_message( "Reset Player!" )
	return true
	
