extends Dialog
class_name ZoneEditorMenuDialog

@onready var cursor_offset_button: CursorOffsetButton = %CursorOffsetButton
@onready var menu_fadeable_panel_container: FadeablePanelContainer = %MenuFadeablePanelContainer

func _on_close_button_pressed() -> void:
#	self._dialog_manager.close_dialog( DialogIds.Id.SETTING_DIALOG, 0.3 )
	var game = self._dialog_manager.game
	game.close_zone_editor()

func open( duration: float ) -> void:
	fade_in( duration )
	menu_fadeable_panel_container.fade_out( 0.0 )
#	cursor_offset_button.connect("pressed", _on_cursor_offset_button_pressed )
	
func close( duration: float ) -> void:
	fade_out( duration )
#	if self.cursor_offset_button != null:
#		cursor_offset_button.disconnect( "pressed", _on_cursor_offset_button_pressed )

func fade_out( duration: float ):
	%FadeablePanelContainer.fade_out( duration )

func fade_in( duration: float ):
	%FadeablePanelContainer.fade_in( duration )

func _on_fadeable_panel_container_on_faded_in() -> void:
	opened()

func _on_fadeable_panel_container_on_faded_out() -> void:
	closed()

func _on_fadeable_panel_container_on_fading_in( _duration: float ) -> void:
	opening()

func _on_fadeable_panel_container_on_fading_out( _duration: float ) -> void:
	closing()

func _on_settings_button_pressed() -> void:
	self._dialog_manager.toggle_dialog( DialogIds.Id.SETTING_DIALOG, 0.3 )


func _on_main_menu_button_pressed() -> void:
	self.menu_fadeable_panel_container.toggle_fade( 0.3 )


func _on_load_button_pressed() -> void:
	var d = self._dialog_manager.open_dialog( DialogIds.Id.ZONE_SELECT_DIALOG, 0.3 )
	var zsd = d as ZoneSelectDialog
	if zsd != null:
		zsd.mode = ZoneSelectDialog.Mode.LOAD
		zsd.clear_filter_prefixes()
		zsd.zone_selected.connect( _on_zone_select_dialog_zone_selected )
		zsd.update_zones()
	self.menu_fadeable_panel_container.fade_out( 0.3 )

func _on_reload_button_pressed() -> void:
	self._dialog_manager.game.reload_zone()
	self.menu_fadeable_panel_container.fade_out( 0.3 )

func _on_save_button_pressed() -> void:
	self._dialog_manager.game.save_zone()
	self.menu_fadeable_panel_container.fade_out( 0.3 )

func _on_save_as_button_pressed() -> void:
	var d = self._dialog_manager.open_dialog( DialogIds.Id.ZONE_SELECT_DIALOG, 0.3 )
	var zsd = d as ZoneSelectDialog
	if zsd != null:
		zsd.mode = ZoneSelectDialog.Mode.SAVE_AS
		zsd.clear_filter_prefixes()
		zsd.add_filter_prefix( "user-" )
		zsd.update_zones()
		zsd.zone_selected.connect( _on_zone_select_dialog_zone_selected )
	self.menu_fadeable_panel_container.fade_out( 0.3 )

func _on_zone_select_dialog_zone_selected( zsd: ZoneSelectDialog, filename: String ) -> void:
	print( "Zone Selected %s" % filename )
	self._dialog_manager.close_dialog( DialogIds.Id.ZONE_SELECT_DIALOG, 0.3 )
	match zsd.mode:
		ZoneSelectDialog.Mode.LOAD:
			self._dialog_manager.game.select_zone( filename )
		ZoneSelectDialog.Mode.SAVE_AS:
			self._dialog_manager.game.select_save_zone( filename )

func _on_clear_button_pressed() -> void:
	self._dialog_manager.game.zone_editor_manager.clear_zone()
	self.menu_fadeable_panel_container.fade_out( 0.3 )


func _on_cursor_offset_button_pressed() -> void:
	# self.cursor_offset_pressed.emit( self.cursor_offset_button.cursor_offset )
	var cursor_offset = self._dialog_manager.game.zone_editor_manager.set_cursor_offset( self.cursor_offset_button.cursor_offset )
	self.cursor_offset_button.cursor_offset = cursor_offset


func _on_zone_test_button_pressed() -> void:
	self._dialog_manager.game.zone_editor_manager.test_zone()
