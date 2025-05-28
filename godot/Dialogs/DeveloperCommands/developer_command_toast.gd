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
		"":
			Events.broadcast_global_message( "Test Toast" )
			
	return true
	
