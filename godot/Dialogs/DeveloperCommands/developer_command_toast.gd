class_name DeveloperCommandToast extends DeveloperCommand

func syntax() -> String:
	return "toast"
	
func run( input: String, game: Game ) -> bool:
	var i = input.trim_prefix( "toast" )
	i = i.strip_edges()
	var parts = i.split(" ")

	if parts.is_empty():
		parts.push_back( "" )
		
	match parts[ 0 ]:
		"achievement":
			Events.broadcast_achievement_completed( "SingleRunDistance1")
		"reward":
			var icon = load("res://Textures/UI/mini_icon_coin.png")
			Events.broadcast_reward_received( 10, icon, "")
			Events.broadcast_reward_received( 0, null, "Developer Love")
		"stream":
			for _i in range(1):
				Events.broadcast_reward_received( 0, null, "Thank you!" )
				Events.broadcast_global_message( "For watching the stream" )
		"":
			Events.broadcast_global_message( "Test Toast" )
		_:
			Events.broadcast_global_message( "Unknown Toast %s" % parts[0] )
	return true
	
