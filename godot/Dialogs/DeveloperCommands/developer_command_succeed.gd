class_name DeveloperCommandSucceed extends DeveloperCommand

func syntax() -> String:
	return "succeed"
	
func run( _input: String, _game: Game ) -> bool:
	return true
	
