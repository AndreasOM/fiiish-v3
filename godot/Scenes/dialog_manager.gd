extends Control
class_name DialogManager

@export var game: Game = null

var _dialog_configs: Dictionary = {
	DialogIds.Id.RESULT_DIALOG: preload("res://Dialogs/result_dialog.tscn"),
#	DialogIds.Id.SETTING_DIALOG: preload("res://Dialogs/setting_dialog.tscn"),
	DialogIds.Id.SKILL_UPGRADE_DIALOG: preload("res://Dialogs/skill_upgrade_dialog.tscn"),
#	DialogIds.Id.SKILL_RESET_CONFIRMATION_DIALOG: preload("res://Dialogs/skill_reset_confirmation_dialog.tscn"),
	DialogIds.Id.SKILL_RESET_CONFIRMATION_DIALOG: preload("res://Dialogs/fiiish_confirmation_dialog.tscn"),
	DialogIds.Id.SKILL_NOT_AFFORDABLE_DIALOG: preload("res://Dialogs/fiiish_confirmation_dialog.tscn"),
	DialogIds.Id.SETTING_DIALOG: preload("res://Dialogs/setting_dialog.tscn"),
	DialogIds.Id.DEVELOPER_CONSOLE_DIALOG: preload("res://Dialogs/developer_console_dialog.tscn"),
	DialogIds.Id.MAIN_MENU_DIALOG: preload("res://Dialogs/main_menu_dialog.tscn"),
	DialogIds.Id.CREDITS_DIALOG: preload("res://Dialogs/credits_dialog.tscn"),
	DialogIds.Id.LEADERBOARD_DIALOG: preload("res://Dialogs/leaderboard_dialog.tscn"),
	DialogIds.Id.ZONE_EDITOR_MENU_DIALOG: preload("res://Dialogs/zone_editor_menu_dialog.tscn"),
	DialogIds.Id.MINI_MAP_DIALOG: preload("res://Dialogs/mini_map_dialog.tscn"),
	DialogIds.Id.ZONE_SELECT_DIALOG: preload("res://Dialogs/zone_select_dialog.tscn"),
	DialogIds.Id.ZONE_EDITOR_TOOLS_DIALOG: preload("res://Dialogs/ZoneEditor/zone_editor_tools_dialog.tscn"),
	DialogIds.Id.ZONE_PROPERTY_DIALOG: preload("res://Dialogs/ZoneEditor/zone_property_dialog.tscn"),
	DialogIds.Id.IN_GAME_PAUSE_DIALOG: preload("res://Scenes/in_game_pause_menu.tscn"),
	DialogIds.Id.ACHIEVEMENTS_DIALOG: preload("res://Features/Achievements/Dialogs/achievement_dialog.tscn"),
#	DialogIds.Id.ACHIEVEMENTS_DIALOG: preload("res://Features/Achievements/Dialogs/achievement_dialog_v1.tscn"),
	DialogIds.Id.TOAST_DIALOG: preload("res://Features/Toasts/Dialogs/toast_dialog.tscn"),
	DialogIds.Id.DEVELOPER_DIALOG: preload("res://Features/DeveloperDialog/developer_dialog.tscn"),
	DialogIds.Id.KIDS_MODE_ENABLE_DIALOG: preload("res://Features/KidsMode/kidsmode_enable_dialog.tscn"),
	DialogIds.Id.ABOUT_DEMO_DIALOG: preload("res://Dialogs/fiiish_confirmation_dialog.tscn"),
}

var _dialogs: Dictionary = {}

var _open_dialogs: Dictionary[ DialogIds.Id, bool ] = {}


func _instantiate_dialog( id: DialogIds.Id ) -> Dialog:
	var dc = _dialog_configs.get( id )
	var d = dc.instantiate()
	var dialog = d as Dialog
	if dialog == null:
		push_warning( "DIALOG_MANAGER: %d is not a dialog" % [ id ] )
		return null
	#if dialog.has_method( "set_dialog_manager" ):
	dialog.set_dialog_manager( self )
	if dialog.has_method( "set_game" ):
		dialog.set_game( game );
	dialog.on_closing.connect( on_dialog_closing )
	dialog.on_closed.connect( on_dialog_closed )
	dialog.on_opening.connect( on_dialog_opening )
	dialog.on_opened.connect( on_dialog_opened )
	dialog.close( 0.0 )
	# dialog.override_z_index( 0 )
	self.add_child( dialog )
	_dialogs[ id ] = dialog
	
	print("DIALOG_MANAGER: dialog instantiated %d -> %s" % [ id, DialogIds.id_to_name( id ) ] )
	return dialog
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# $SkillUpgradeDialog.fade_out( 0.0 )
	## for id in _dialog_configs.keys():
	##	self._instatiate_dialog( id )
			
	# open_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )
	
	Events.zone_edit_enabled.connect( _on_zone_edit_enabled )
	Events.zone_edit_disabled.connect( _on_zone_edit_disabled )
	
	for c in self.get_children():
		var dialog = c as Dialog
		if dialog != null:
			if dialog.has_method( "set_game" ):
				dialog.set_game( game );

func on_dialog_closing( dialog: Dialog ) -> void:
	print( "DIALOG_MANAGER: on_dialog_closing %s" % dialog.name )

func on_dialog_closed( dialog: Dialog ) -> void:
	print( "DIALOG_MANAGER: on_dialog_closed %s" % dialog.name )
	dialog.visible = false
	if dialog.get_parent_control() == self:
		self.remove_child( dialog )
	else:
		print("WARN: dialog is not a child of DialogManager")
	var id = _dialogs.find_key( dialog )
	if id != null:
		_dialogs.erase( id )
	self._open_dialogs[ dialog.get_id() ] = false

func on_dialog_opening( dialog: Dialog ) -> void:
	print( "DIALOG_MANAGER: on_dialog_opening %s" % dialog.name )
	dialog.visible = true

func on_dialog_opened( dialog: Dialog ) -> void:
	print( "DIALOG_MANAGER: on_dialog_opened %s" % dialog.name )
	self._open_dialogs[ dialog.get_id() ] = true
	
func _on_skills_upgrade_button_pressed() -> void:
	print("DIALOG_MANAGER: Skills upgrade button pressed")
	open_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )

func is_dialog_open( id: DialogIds.Id ) -> bool:
	return _open_dialogs.get( id, false )

func is_dialog_closed( id: DialogIds.Id ) -> bool:
	return !_open_dialogs.get( id, false )

func toggle_dialog( id: DialogIds.Id, duration: float) -> void:
	var dialog = _dialogs.get( id ) as Dialog
	if dialog == null:
		# dialog = self.open_dialog(id, 0.3)
		dialog = self._instantiate_dialog(id)
	if dialog != null:
		dialog.toggle( duration )
	else:
		push_warning("DIALOG_MANAGER: Dialog %d not found for toggle" % id )


func get_dialog( id: DialogIds.Id ) -> Dialog:
	var dialog = _dialogs.get( id ) as Dialog
	if dialog == null:
		push_warning("DIALOG_MANAGER: Dialog %d not found" % id )
		return null
		
	return dialog
	
func open_dialog( id: DialogIds.Id, duration: float) -> Dialog:
	print("DIALOG_MANAGER: open_dialog %d -> %s" % [ id, DialogIds.id_to_name( id ) ] )
	var dialog = _dialogs.get( id ) as Dialog
	if dialog != null:
		print("DIALOG_MANAGER: Dialog %d already open" % id )
		# push_warning("DIALOG_MANAGER: Dialog %d already open" % id )
		return dialog
	dialog = self._instantiate_dialog(id)
	dialog.set_id( id )
	dialog.open( duration )
	dialog.visible = true
	return dialog
	
func open_dialog_v1( id: DialogIds.Id, duration: float) -> Dialog:
	var dialog = _dialogs.get( id ) as Dialog
	if dialog != null:
		print("DIALOG_MANAGER: Opening dialog %d" % id)
		dialog.open( duration )
		dialog.visible = true
		return dialog
	else:
		print("DIALOG_MANAGER: Dialog %d not found for open" % id )
		push_warning("DIALOG_MANAGER: Dialog %d not found for open" % id )
		return null

func close_dialog( id: DialogIds.Id, duration: float) -> void:
	var dialog = _dialogs.get( id ) as Dialog
	if dialog == null:
		print("DIALOG_MANAGER: Dialog %d not found for close" % id )
		# push_warning("DIALOG_MANAGER: Dialog %d not found for close" % id )
		return
		
	dialog.close( duration )
	
	## cleanup will be done in on_dialog_closed callback
	# dialog.visible = false
	# self.remove_child( dialog )
	# _dialogs.erase( id )

func close_dialog_v1( id: DialogIds.Id, duration: float) -> void:
	var dialog = _dialogs.get( id ) as Dialog
	if dialog != null:
		print("DIALOG_MANAGER: Closing dialog %d" % id)
		dialog.close( duration )
		dialog.visible = false
	else:
		print("DIALOG_MANAGER: Dialog %d not found for close" % id )
		push_warning("DIALOG_MANAGER: Dialog %d not found for close" % id )
	

func _on_game_state_changed(state: Game.State) -> void:
	print("DIALOG_MANAGER: _on_game_state_changed %d -> %s" % [ state, game.state_to_name( state ) ] )
	match state:
		# Game.State.DYING:
		Game.State.DEAD:
#			close_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )
#			open_dialog( DialogIds.Id.RESULT_DIALOG, 0.3 )
			pass
		Game.State.RESULT:
			close_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.ACHIEVEMENTS_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.LEADERBOARD_DIALOG, 0.3 )
			open_dialog( DialogIds.Id.RESULT_DIALOG, 0.3 )
		Game.State.PREPARING_FOR_START:
			close_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.ACHIEVEMENTS_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.LEADERBOARD_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.RESULT_DIALOG, 0.3 )
		Game.State.WAITING_FOR_START:
			close_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.ACHIEVEMENTS_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.LEADERBOARD_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.RESULT_DIALOG, 0.3 )
		Game.State.SWIMMING:
			close_dialog( DialogIds.Id.SKILL_UPGRADE_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.ACHIEVEMENTS_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.LEADERBOARD_DIALOG, 0.3 )
			close_dialog( DialogIds.Id.RESULT_DIALOG, 0.3 )
		_:
			pass

func _on_zone_edit_enabled() -> void:
	# %InGamePauseMenu.visible = false
	self.close_dialog( DialogIds.Id.IN_GAME_PAUSE_DIALOG, 0.3 )

	var dialog = self.open_dialog( DialogIds.Id.ZONE_EDITOR_TOOLS_DIALOG, 0.3 )
	var tools_dialog = dialog as ZoneEditorToolsDialog
	if tools_dialog != null:
		var tid = tools_dialog.last_selected_tool_id
		self._on_zone_editor_tool_selected( tid )
		tools_dialog.tool_selected.connect( _on_zone_editor_tool_selected )
		tools_dialog.undo_pressed.connect( _on_zoned_editor_undo_pressed )
		tools_dialog.redo_pressed.connect( _on_zoned_editor_redo_pressed )
		tools_dialog.spawn_entity_changed.connect( _on_zone_editor_spawn_entity_changed )
		self.game.zone_editor_manager.command_history_size_changed.connect( _on_zone_editor_manager_command_history_size_changed )

	self.open_dialog( DialogIds.Id.ZONE_EDITOR_MENU_DIALOG, 0.3 )

	var zone_property_dialog = self.open_dialog( DialogIds.Id.ZONE_PROPERTY_DIALOG, 0.3 ) as ZonePropertyDialog
	if zone_property_dialog != null:
		zone_property_dialog.set_stop_testing_enabled( false )
		zone_property_dialog.zone_editing_enabled = true
		
		zone_property_dialog.zone_name_submitted.connect( self.game.zone_editor_manager.on_zone_name_submitted )
		self.game.zone_editor_manager.zone_name_changed.connect( zone_property_dialog.on_zone_name_changed )
		zone_property_dialog.on_zone_name_changed( self.game.zone_editor_manager.get_zone_name() )
		
		zone_property_dialog.difficulty_changed.connect( self.game.zone_editor_manager.on_zone_difficulty_changed )
		self.game.zone_editor_manager.zone_difficulty_changed.connect( zone_property_dialog.on_zone_difficulty_changed )
		zone_property_dialog.on_zone_difficulty_changed( self.game.zone_editor_manager.get_zone_difficulty() )
	
		zone_property_dialog.zone_width_changed.connect( self.game.zone_editor_manager.on_zone_width_changed )
		self.game.zone_editor_manager.zone_width_changed.connect( zone_property_dialog.on_zone_width_changed )
		zone_property_dialog.on_zone_width_changed( self.game.zone_editor_manager.get_zone_width() )

func _on_zone_edit_disabled() -> void:
	# %InGamePauseMenu.visible = true
	self.open_dialog( DialogIds.Id.IN_GAME_PAUSE_DIALOG, 0.3 )

	self.close_dialog( DialogIds.Id.ZONE_EDITOR_MENU_DIALOG, 0.3 )
	self.close_dialog( DialogIds.Id.ZONE_EDITOR_TOOLS_DIALOG, 0.3 )
	
	if !self.game.get_game_manager().has_test_zone():
		self.close_dialog( DialogIds.Id.ZONE_PROPERTY_DIALOG, 0.3 )
	else:
		var dialog = _dialogs.get( DialogIds.Id.ZONE_PROPERTY_DIALOG ) as Dialog
		var zone_property_dialog = dialog as ZonePropertyDialog
		if zone_property_dialog != null:
			zone_property_dialog.set_stop_testing_enabled( true )
			zone_property_dialog.zone_editing_enabled = false

func _on_zone_editor_tool_selected( tool_id: ZoneEditorToolIds.Id ) -> void:
	self.game._on_zone_editor_tool_selected( tool_id )

func _on_zoned_editor_undo_pressed() -> void:
	self.game._on_zone_editor_undo_pressed()

func _on_zoned_editor_redo_pressed() -> void:
	self.game._on_zone_editor_redo_pressed()

func _on_zone_editor_manager_command_history_size_changed( history_size: int, future_size: int ) -> void:
	var tools_dialog = _dialogs.get( DialogIds.Id.ZONE_EDITOR_TOOLS_DIALOG ) as ZoneEditorToolsDialog
	if tools_dialog != null:
		tools_dialog.on_command_history_size_changed( history_size, future_size )

func _on_zone_editor_spawn_entity_changed( id: EntityId.Id ) -> void:
	self.game._on_zone_editor_spawn_entity_changed( id )
