class_name DeveloperCommandSucceed extends DeveloperCommand

func syntax() -> String:
	return "succeed"
	
func run( input: String, game: Game ) -> bool:
	return true
	
