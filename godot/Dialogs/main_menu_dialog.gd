extends Dialog
class_name MainMenuDialog

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


func _on_credits_button_pressed() -> void:
	print("Credits pressed")
	_dialog_manager.open_dialog( DialogIds.Id.CREDITS_DIALOG, 0.3 )
