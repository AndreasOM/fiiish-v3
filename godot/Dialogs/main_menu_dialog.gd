extends Dialog
class_name MainMenuDialog

var game: Game = null

func set_game( game: Game ):
	self.game = game
	
func toggle( duration: float ):
	toggle_fade( duration )

func close( duration: float):
	fade_out( duration )

func open( duration: float):
	fade_in( duration )

func toggle_fade( duration: float ):
	$MainMenuFadeableContainer.toggle_fade( duration )

func fade_in( duration: float ):
	$MainMenuFadeableContainer.fade_in( duration )

func fade_out( duration: float ):
	$MainMenuFadeableContainer.fade_out( duration )


func _on_zone_editor_pressed() -> void:
	pass # Replace with function body.

func _on_credits_pressed() -> void:
	print("Credits pressed")
	_dialog_manager.open_dialog( DialogIds.Id.CREDITS_DIALOG, 0.3 )

func _on_quit_pressed() -> void:
	pass # Replace with function body.

func _on_leader_board_pressed() -> void:
	pass # Replace with function body.

func _on_game_mode_pressed() -> void:
	var mode = self.game.next_game_mode()
	var name = GameModes.get_name_for_mode( mode )
	%GameMode.label = "GameMode: %s" % name

func _on_main_menu_fadeable_container_on_fading_in() -> void:
	%LeaderBoard.grab_focus.call_deferred()
