class_name DeveloperDialog
extends Dialog


func open( duration: float) -> void:
	var _desktop_only: Array [ Control ] = [
		%"1920x1080TextureButton",
		%"960x540TextureButton",
	]
	
	match OS.get_name():
		"Android", "iOS", "Web":
			for e in _desktop_only:
				var c: Control = e
				if c != null:
					c.visible = false
		_:
			pass
	fade_in( duration )

func close( duration: float) -> void:
	fade_out( duration )

func toggle( duration: float ) -> void:
	toggle_fade( duration )

func toggle_fade( duration: float ) -> void:
	%FadeablePanelContainer.toggle_fade( duration )

func fade_out( duration: float ) -> void:
	%FadeablePanelContainer.fade_out( duration )

func fade_in( duration: float ) -> void:
	%FadeablePanelContainer.fade_in( duration )

func _on_fadeable_panel_container_on_faded_in() -> void:
	opened()

func _on_fadeable_panel_container_on_faded_out() -> void:
	closed()

func _on_fadeable_panel_container_on_fading_in( _duration: float ) -> void:
	opening()

func _on_fadeable_panel_container_on_fading_out( _duration: float ) -> void:
	closing()


func _on_enable_kids_mode_texture_button_pressed() -> void:
	if self._dialog_manager.game.is_in_kids_mode():
		self._dialog_manager.game.leave_kids_mode()
	else:
		self._dialog_manager.open_dialog( DialogIds.Id.KIDS_MODE_ENABLE_DIALOG, 0.3 )


func _on_x_1080_texture_button_pressed() -> void:
	get_window().size = Vector2i( 1920, 1080 )


func _on_x_540_texture_button_pressed() -> void:
	get_window().size = Vector2i( 960, 540 )
