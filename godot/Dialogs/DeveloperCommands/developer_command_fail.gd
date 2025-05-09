class_name DeveloperCommandFail extends DeveloperCommand

func syntax() -> String:
	return "fail"
	
func run( _input: String, _game: Game ) -> bool:
	return false
	
