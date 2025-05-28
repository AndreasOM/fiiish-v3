class_name DeveloperCommandToast extends DeveloperCommand

func syntax() -> String:
	return "toast"
	
func run( _input: String, game: Game ) -> bool:
	Events.broadcast_global_message( "Test Toast" )
	return true
	
