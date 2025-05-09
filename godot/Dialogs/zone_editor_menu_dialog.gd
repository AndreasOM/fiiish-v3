extends Dialog
class_name ZoneEditorMenuDialog

@onready var sub_menu_v_box_container: VBoxContainer = %SubMenuVBoxContainer

func _on_close_button_pressed() -> void:
	self._dialog_manager.close_dialog( DialogIds.Id.SETTING_DIALOG, 0.3 )
	var game = self._dialog_manager.game
	game.close_zone_editor()

func open( _duration: float ) -> void:
	sub_menu_v_box_container.visible = false
	
func close( _duration: float ) -> void:
	closed()


func _on_settings_button_pressed() -> void:
	self._dialog_manager.toggle_dialog( DialogIds.Id.SETTING_DIALOG, 0.3 )


func _on_main_menu_button_pressed() -> void:
	%SubMenuVBoxContainer.visible = !%SubMenuVBoxContainer.visible


func _on_load_button_pressed() -> void:
	var d = self._dialog_manager.open_dialog( DialogIds.Id.ZONE_SELECT_DIALOG, 0.3 )
	var zsd = d as ZoneSelectDialog
	if zsd != null:
		zsd.mode = ZoneSelectDialog.Mode.LOAD
		zsd.clear_filter_prefixes()
		zsd.zone_selected.connect( _on_zone_select_dialog_zone_selected )
		zsd.update_zones()
	%SubMenuVBoxContainer.visible = false

func _on_save_as_button_pressed() -> void:
	var d = self._dialog_manager.open_dialog( DialogIds.Id.ZONE_SELECT_DIALOG, 0.3 )
	var zsd = d as ZoneSelectDialog
	if zsd != null:
		zsd.mode = ZoneSelectDialog.Mode.SAVE_AS
		zsd.clear_filter_prefixes()
		zsd.add_filter_prefix( "user-" )
		zsd.update_zones()
		zsd.zone_selected.connect( _on_zone_select_dialog_zone_selected )
	%SubMenuVBoxContainer.visible = false

func _on_zone_select_dialog_zone_selected( zsd: ZoneSelectDialog, filename: String ) -> void:
	print( "Zone Selected %s" % filename )
	self._dialog_manager.close_dialog( DialogIds.Id.ZONE_SELECT_DIALOG, 0.3 )
	match zsd.mode:
		ZoneSelectDialog.Mode.LOAD:
			self._dialog_manager.game.select_zone( filename )
		ZoneSelectDialog.Mode.SAVE_AS:
			self._dialog_manager.game.select_save_zone( filename )
