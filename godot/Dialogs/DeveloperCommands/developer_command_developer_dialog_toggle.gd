class_name DeveloperCommandDeveloperDialogToggle extends DeveloperCommand

func syntax() -> String:
	return "developer_dialog_toggle"
	
func run( _input: String, game: Game ) -> bool:
	var settings = game.get_settings()
	
	if settings.get_developer_dialog_version() > 0:
		settings.set_developer_dialog_version( 0 )
		print( "Disabled developer dialog")
	else:
		settings.set_developer_dialog_version( 1 )
		print( "Enabled developer dialog")

	settings.save()
	
	Events.broadcast_settings_changed()
	
	return true
	
