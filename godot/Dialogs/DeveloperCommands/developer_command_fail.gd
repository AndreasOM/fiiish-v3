class_name DeveloperCommandFail extends DeveloperCommand

func syntax() -> String:
	return "fail"
	
func run( input: String, game: Game ) -> bool:
	return false
	
