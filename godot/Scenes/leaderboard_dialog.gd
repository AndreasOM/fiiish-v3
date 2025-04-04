extends Dialog
class_name LeaderboardDialog


func close( duration: float):
	fade_out( duration )

func open( duration: float):
	fade_in( duration )

func fade_out( duration: float ):
	%FadeablePanelContainer.fade_out( duration )

func fade_in( duration: float ):
	%FadeablePanelContainer.fade_in( duration )

func _on_close_button_pressed() -> void:
	# print( "Leaderboard Close")
	self._dialog_manager.close_dialog(DialogIds.Id.LEADERBOARD_DIALOG, 0.3)


func _on_fadeable_panel_container_on_faded_in() -> void:
	opened()

func _on_fadeable_panel_container_on_faded_out() -> void:
	closed()

func _on_fadeable_panel_container_on_fading_in() -> void:
	opening()

func _on_fadeable_panel_container_on_fading_out() -> void:
	closing()
