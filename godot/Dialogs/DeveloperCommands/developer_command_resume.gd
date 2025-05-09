class_name DeveloperCommandResume extends DeveloperCommand

func syntax() -> String:
	return "resume"
	
func run( _input: String, game: Game ) -> bool:
	game.resume()
	return true
	
