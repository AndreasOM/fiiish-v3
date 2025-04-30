extends Dialog
class_name ZoneEditorMenuDialog


func _on_close_button_pressed() -> void:
	self._dialog_manager.close_dialog( DialogIds.Id.SETTING_DIALOG, 0.3 )
	var game = self._dialog_manager.game
	game.close_zone_editor()

func close( _duration: float ) -> void:
	closed()


func _on_settings_button_pressed() -> void:
	self._dialog_manager.toggle_dialog( DialogIds.Id.SETTING_DIALOG, 0.3 )


func _on_main_menu_button_pressed() -> void:
	%TodoTextureRect.visible = !%TodoTextureRect.visible
